Purpose of this document
This guide equips Flutter developers to integrate the mobile client with the Parlvote backend. It covers authentication, REST endpoints, WebSocket (STOMP) real‑time channels, data flows, payload schemas, security rules, and example Dart code.
Base URLs, environments, and tools
•
REST Base URL (dev default): http://localhost:8080
•
WebSocket endpoint: ws://localhost:8080/ws
•
Docs (Swagger UI): http://localhost:8080/swagger-ui
•
OpenAPI spec: http://localhost:8080/v3/api-docs
•
Mongo (local via Docker): mongodb://root:rootpass@localhost:27017/parlvote?authSource=admin
Notes for emulator/device:
•
Android emulator can reach host via http://10.0.2.2:8080.
•
Physical devices need your PC’s LAN IP: http://192.168.x.y:8080.
•

•
JWT RS256 access tokens (default TTL: 15 minutes) and refresh tokens (default TTL: 7 days).
•
Obtain tokens via POST /auth/login.
•
Refresh access token via POST /auth/refresh.
•
Include Authorization: Bearer <accessToken> header on all protected REST calls.
•
WebSocket: send the JWT inside the STOMP CONNECT frame header authorization: Bearer <token>.
JWT claims (access/refresh):
•
sub: username
•
uid: user id
•
displayName: display name
•
roles: array, e.g. ["ADMIN"] or ["USER"]
•
typ: "access" or "refresh"
Seed accounts in dev:
•
Admin: admin / admin123
•
Members: member1..member5 / member123
Auth endpoints and examples
•
POST /auth/login → { accessToken, refreshToken, user }
•
POST /auth/refresh → { accessToken } (requires refresh token in body)
•
GET /auth/me → current user
Example login request/response:
POST /auth/login
Content-Type: application/json
{
  "username": "member1",
  "password": "member123"
}
200 OK
{
  "accessToken": "<JWT>",
  "refreshToken": "<JWT>",
  "user": { "id": "...", "username": "member1", "displayName": "Member 1", "role": "USER" }
}
Refresh:
POST /auth/refresh
Content-Type: application/json
{ "refreshToken": "<JWT>" }
Error envelope (standardized):
{
  "timestamp": "2025-10-17T09:12:34Z",
  "path": "/auth/login",
  "code": "AUTH_INVALID",
  "message": "Invalid username or password"
}
WebSocket (STOMP) integration
•
Endpoint: /ws (permit‑all for HTTP handshake; auth at STOMP layer)
•
Subprotocol: v12.stomp
•
STOMP CONNECT headers must include authorization: Bearer <accessToken>
•
User queue prefix: /user
•
Application prefix: /app
•
Broker topics: /topic, /queue
Client → Server destinations:
•
/app/sessions/{sessionId}/heartbeat body: { "ts": 1739724000000 } (epoch ms recommended, a simple Long)
◦
Only updates activity if the user already joined via REST; no auto‑join.
Server → Client topics and events:
•
Session topic: /topic/sessions/{sessionId}
◦
session.updated → { type: "session.updated", session: Session }
◦
attendance.updated → { type: "attendance.updated", activeCount, ts }
◦
agenda.updated → { type: "agenda.updated", sessionId, text? or file? }
◦
document.shared → { type: "document.shared", doc: { id, title, kind, sizeBytes, ownerId } }
◦
decision.opened → { type: "decision.opened", decisionId, closeAt }
◦
vote.tally → { type: "vote.tally", decisionId, accepted, denied, abstained, valid, activeBase }
◦
decision.closed → { type: "decision.closed", decisionId, result } where result={accepted,denied,abstained,valid,activeBase,passed}
◦
handraise.updated → { type: "handraise.updated", item: HandRaise }
◦
mute.updated → { type: "mute.updated", userId, until? }
•
Direct messages: /user/queue/dm → { type: "chat.message", message: Message }
•
Group topic: /topic/groups/{groupId} → { type: "chat.message", message: Message }
•
Errors: /user/queue/errors → { code, message, destination }
Subscribe authorization (enforced on SUBSCRIBE):
•
/topic/sessions/{sessionId} requires active attendee (joined and not left).
•
/topic/groups/{groupId} requires group membership (or owner).
•
Rejection sends an error to /user/queue/errors and the subscription is denied.
Heartbeat and “active” calculation:
•
Mobile clients should send a heartbeat message every ~10s: /app/sessions/{id}/heartbeat with { ts: nowMs }.
•
A user is “active” if last heartbeat ≤ 30s ago (configurable: app.ws.heartbeatGraceSeconds).
Dart example (stomp_dart_client):
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class WsService {
  StompClient? _client;

  void connect(String baseWsUrl, String accessToken) {
    _client = StompClient(
      config: StompConfig(
        url: baseWsUrl, // e.g. ws://10.0.2.2:8080/ws
        onConnect: _onConnect,
        onStompError: (f) => print('STOMP error: ${f.body}'),
        onWebSocketError: (e) => print('WS error: $e'),
        stompConnectHeaders: {
          'authorization': 'Bearer $accessToken',
          'accept-version': '1.2',
          'host': 'localhost',
        },
        webSocketConnectHeaders: {
          // HTTP headers don’t carry auth in this app; auth is in STOMP headers
        },
        connectionTimeout: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 0),
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    print('Connected');
    // Subscribe to personal DM queue
    _client!.subscribe(
      destination: '/user/queue/dm',
      callback: (msg) => print('DM event: ${msg.body}'),
    );
  }

  void subscribeSession(String sessionId, void Function(String body) onEvent) {
    _client?.subscribe(
      destination: '/topic/sessions/$sessionId',
      callback: (msg) => onEvent(msg.body ?? ''),
    );
  }

  void sendHeartbeat(String sessionId) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    _client?.send(destination: '/app/sessions/$sessionId/heartbeat', body: '{"ts":$ts}');
  }

  void dispose() {
    _client?.deactivate();
  }
}
Core user flows (step‑by‑step)
1) Sign in and token refresh
•
Call /auth/login → store accessToken, refreshToken, and user.
•
Add Authorization: Bearer <accessToken> to every REST call.
•
On 401 for expired access token, call /auth/refresh with { refreshToken }, update the stored access token, retry the original request.
2) Join a session and receive real‑time updates
•
Discover sessions: GET /sessions?status=LIVE.
•
Join: POST /sessions/{id}/join.
•
Connect STOMP and subscribe to /topic/sessions/{id}.
•
Send periodic heartbeats to /app/sessions/{id}/heartbeat every ~10s.
•
Handle incoming events: attendance updates, agenda updates, document shares, decision open/close, vote tallies, speaking queue changes, mute.
3) Vote on a decision
•
List decisions: GET /sessions/{id}/decisions.
•
When a decision is OPEN, POST /decisions/{dId}/votes with { choice: ACCEPT|DENY|ABSTAIN, seq }.
◦
seq is a client monotonic counter per decision/user; reusing a lower or equal seq is ignored (idempotency and out‑of‑order protection).
◦
Voting requires the user to be an attendee and the session not PAUSED/ARCHIVED.
•
Listen to vote.tally while open and decision.closed on close.
4) Chat (DM and groups)
•
DM history: GET /messages/dm/{otherUserId}.
•
Group list/manage: POST /groups, PATCH /groups/{gId}, GET /groups, GET /groups/{gId}.
•
Group history: GET /messages/group/{groupId}.
•
Send message: POST /messages with body depending on type:
◦
DM: { "type":"DM", "toUserId":"...", "text":"hello" }
◦
GROUP: { "type":"GROUP", "groupId":"...", "text":"hello" }
•
Delivery happens in real time via STOMP:
◦
DM: /user/queue/dm to both sender and recipient.
◦
Group: /topic/groups/{groupId} (must be subscribed and member).
•
Muted users cannot send messages (server returns 403 MUTED).
5) Agenda and documents
•
Update agenda text (admin): POST /sessions/{id}/agenda/text with { text }.
•
Attach file to agenda (admin): POST /sessions/{id}/agenda/file (multipart) → triggers agenda.updated WS.
•
Upload document (any user): POST /documents (multipart) with fields:
◦
file (binary)
◦
sessionId (optional)
◦
scope: ADMIN_ONLY or ALL
◦
title (optional)
•
List session docs (attendee/admin): GET /sessions/{id}/documents.
•
Download doc: GET /documents/{docId} (authenticated streaming; access depends on scope and attendance/ownership).
6) Speaking queue and mute
•
Raise hand (member): POST /sessions/{id}/hand-raises.
•
Admin views queue: GET /sessions/{id}/hand-raises.
•
Admin actions: POST /hand-raises/{hrId}/approve|deny|skip|mark-spoken.
•
Reorder (admin): POST /sessions/{id}/hand-raises/reorder with { orderedIds: ["..."] }.
•
Mute user (admin): POST /sessions/{id}/mute/{userId} with { minutes?: number } (default 5).
•
Unmute: DELETE /sessions/{id}/mute/{userId}.
•
Related events are broadcast on /topic/sessions/{id}.
REST API reference (practical cheat sheet)
Auth
•
POST /auth/login → { accessToken, refreshToken, user }
•
POST /auth/refresh → { accessToken }
•
GET /auth/me → user
Sessions
•
POST /sessions (ADMIN) { name } → create DRAFT
•
GET /sessions?status=LIVE|DRAFT|PAUSED|CLOSED|ARCHIVED → list
•
GET /sessions/{id} → details
•
POST /sessions/{id}/open|pause|close|archive (ADMIN)
•
POST /sessions/{id}/join → become attendee
•
POST /sessions/{id}/leave → leave session
Agenda & Documents
•
POST /sessions/{id}/agenda/text (ADMIN) { text }
•
POST /sessions/{id}/agenda/file (ADMIN) multipart
•
POST /documents multipart { file, sessionId?, scope, title? }
•
GET /sessions/{id}/documents → list (attendee/admin visibility)
•
GET /documents/{docId} → stream
Decisions & Votes
•
POST /sessions/{id}/decisions (ADMIN) { title, description?, allowRecast? }
•
GET /sessions/{id}/decisions → list
•
GET /decisions/{dId} → details + computed tally
•
POST /decisions/{dId}/open (ADMIN) { closeAt: ISO-8601 }
•
POST /decisions/{dId}/close (ADMIN)
•
POST /decisions/{dId}/votes { choice, seq }
•
GET /decisions/{dId}/votes → public per-member votes (session members/admins only)
Speaking & Mute
•
POST /sessions/{id}/hand-raises
•
GET /sessions/{id}/hand-raises (ADMIN)
•
POST /hand-raises/{hrId}/approve|deny|skip|mark-spoken (ADMIN)
•
POST /sessions/{id}/hand-raises/reorder (ADMIN) { orderedIds: ["..."] }
•
POST /sessions/{id}/mute/{userId} (ADMIN) { minutes? }
•
DELETE /sessions/{id}/mute/{userId} (ADMIN)
Chat & Groups
•
POST /groups { name, memberIds[] } (owner auto-member)
•
PATCH /groups/{gId} { name?, addMembers?, removeMembers? } (owner only)
•
GET /groups → groups I own/belong to
•
GET /groups/{gId} → details (members only)
•
GET /messages/dm/{userId} → DM history
•
GET /messages/group/{groupId} → group history (members only)
•
POST /messages (DM or GROUP)
Typical response codes and error codes:
•
400: BAD_REQUEST, VALIDATION_ERROR, DM_MISSING_TARGET, GROUP_MISSING_ID
•
401: AUTH_INVALID, generic unauthorized
•
403: FORBIDDEN, NOT_ATTENDEE, MUTED, ACCESS_DENIED
•
404: NOT_FOUND
•
409: INVALID_STATE, SESSION_ARCHIVED, DECISION_NOT_OPEN, SESSION_PAUSED
•
500: SERVER_ERROR, UPLOAD_FAILED
Voting computation (client display)
At decision close:
•
activeBase = count of attendees with heartbeat within 30s at close.
•
valid = accepted + denied; pass if accepted > denied (ties fail).
•
Display percentages vs activeBase:
◦
%accept = accepted / activeBase
◦
%deny = denied / activeBase
◦
%abstain = abstained / activeBase
◦
%turnout = (accepted + denied + abstained) / activeBase
While decision is open, you receive vote.tally updates with the same fields to live‑update UI.
Flutter HTTP examples
Using http package:
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  String? _accessToken;
  String? _refreshToken;

  ApiClient(this.baseUrl);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200) {
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      return data['user'];
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<http.Response> _authedGet(String path) async {
    final resp = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    if (resp.statusCode == 401 && _refreshToken != null) {
      await _refresh();
      return http.get(Uri.parse('$baseUrl$path'), headers: {'Authorization': 'Bearer $_accessToken'});
    }
    return resp;
  }

  Future<void> _refresh() async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': _refreshToken}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _accessToken = data['accessToken'];
    } else {
      throw Exception('Token refresh failed');
    }
  }
}
Multipart upload (documents):
import 'package:http/http.dart' as http;

Future<void> uploadDocument(String baseUrl, String token, String filePath, {
  String? sessionId, required String scope, String? title,
}) async {
  final uri = Uri.parse('$baseUrl/documents');
  final req = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..fields['scope'] = scope; // ADMIN_ONLY or ALL
  if (sessionId != null) req.fields['sessionId'] = sessionId;
  if (title != null) req.fields['title'] = title;
  req.files.add(await http.MultipartFile.fromPath('file', filePath));
  final resp = await req.send();
  if (resp.statusCode != 201) {
    final body = await resp.stream.bytesToString();
    throw Exception('Upload failed: ${resp.statusCode} $body');
  }
}
Client responsibilities and constraints
•
Always join a session via POST /sessions/{id}/join before:
◦
Subscribing to /topic/sessions/{id}
◦
Sending WS heartbeat
◦
Voting and listing session documents
•
Send WS heartbeat every ~10s while participating. If you pause or background, you may be considered inactive after 30s.
•
Use seq monotonic counters when voting (per decision per user): 1,2,3…; reusing old seq is ignored.
•
Handle SESSION_PAUSED and SESSION_ARCHIVED conflict errors by disabling voting and relevant UI.
•
Respect mute status; if MUTED, disable message send UI.
•
For file downloads (GET /documents/{docId}), render inline if possible; content type is set server‑side; Content-Disposition header suggests a filename.
Troubleshooting
•
WS handshake 401: ensure /ws is reachable and you send JWT in STOMP headers on CONNECT. The HTTP Authorization header is not used by the WS auth in this app.
•
Subscribing rejected with error on /user/queue/errors:
◦
NOT_ATTENDEE: call /sessions/{id}/join first.
◦
FORBIDDEN for group: add user to the group / use correct account.
•
Voting 403 NOT_ATTENDEE: join session first.
•
Voting 409 DECISION_NOT_OPEN or SESSION_PAUSED or SESSION_ARCHIVED: disable vote UI.
•
Upload UPLOAD_FAILED (500): retry; ensure backend has write permissions to app.storage.baseDir.
•
401 on login with seed accounts: your DB might have stale users; ask backend to reset or delete conflicting documents.
Minimal event and DTO sketches (for client models)
Session (simplified):
{
  "id":"...",
  "name":"Demo Session",
  "status":"LIVE",
  "agendaText":"...",
  "adminId":"...",
  "createdAt":"2025-10-16T20:00:00Z",
  "openedAt":"2025-10-16T20:05:00Z",
  "closedAt":null,
  "archivedAt":null
}
Decision and tally:
{
  "decision": {"id":"...","sessionId":"...","title":"...","status":"OPEN","openAt":"...","closeAt":"...","allowRecast":true},
  "tally": {"accepted":1,"denied":0,"abstained":0,"valid":1,"activeBase":1}
}
Vote:
{"id":"...","decisionId":"...","userId":"...","choice":"ACCEPT","castAt":"...","seq":1}
Document:
{"id":"...","ownerId":"...","sessionId":"...","title":"file.pdf","kind":"PDF","sizeBytes":12345,"scope":"ALL","uploadedAt":"..."}
Message (DM/GROUP):
{"id":"...","type":"DM","fromUserId":"...","toUserId":"...","text":"hello","sentAt":"..."}
HandRaise:
{"id":"...","sessionId":"...","userId":"...","status":"PENDING","position":1,"requestedAt":"...","updatedAt":"..."}
WS error:
{"code":"NOT_ATTENDEE","message":"You must join the session to subscribe","destination":"/topic/sessions/XYZ"}
Acceptance checklist mapping (client side)
•
Auth works (login/refresh), bearer applied globally.
•
Session join enables WS subscribe; heartbeats keep the user active and attendance updates are visible.
•
Admin pushes agenda text/file; clients receive agenda.updated immediately.
•
Users upload docs; attendees/admins can list and download as per scope.
•
Decision open/close events arrive; voting with seq updates live tallies; final result computed on decision.closed.
•
Speaking queue changes reflected in WS; mute blocks chat and hand‑raise.
•
DM and group chat deliver instantly to subscribed destinations; group membership enforced on subscribe.
Appendix: Example Flutter integration architecture
•
Data layer
◦
AuthRepository: login, refresh, token storage (secure storage), auth state
◦
SessionsRepository: list, join/leave, subscribe, heartbeat timer
◦
DecisionsRepository: list, get, vote (with seq), observe tallies
◦
DocumentsRepository: upload (multipart), list, download URLs/streams
◦
ChatRepository: histories, post, WS subscriptions (DM and groups)
◦
SpeakingRepository: hand‑raises, admin actions, reorder, mute
•
Realtime layer
◦
Single WsService managing STOMP connection using latest access token, auto‑reconnect, topic subscriptions per current session/group
◦
Heartbeat scheduler per joined session
•
UI/State
◦
Show per-session stream of events; update local caches accordingly

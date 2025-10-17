# Session Management Integration Guide

## Overview

The session management system has been fully integrated with the Parlvote backend API. This allows members to view live sessions, join/leave sessions, and admins to manage session lifecycles.

## What Has Been Implemented

### 1. Session Model Updates (`lib/models/session_model.dart`)

Updated to match backend API schema:

```dart
enum SessionStatus {
  draft,    // DRAFT - newly created session
  live,     // LIVE - active session
  paused,   // PAUSED - temporarily paused
  closed,   // CLOSED - ended session
  archived  // ARCHIVED - archived session
}

class SessionModel {
  final String id;
  final String name;              // Session name
  final SessionStatus status;     // Current status
  final String? agendaText;       // Agenda content
  final String adminId;           // Admin who created it
  final DateTime createdAt;       // Creation timestamp
  final DateTime? openedAt;       // When it was opened
  final DateTime? closedAt;       // When it was closed
  final DateTime? archivedAt;     // When it was archived
}
```

**Backward Compatibility:** Added helper getters to work with existing UI:
- `title` → maps to `name`
- `isActive` → `true` if status is LIVE
- `speaker` → temporary placeholder from agendaText
- `startTime` → openedAt or createdAt
- `endTime` → closedAt or estimated time

### 2. Session Service (`lib/services/session_service.dart`)

New service with all session-related API methods:

#### Member Methods:
```dart
// Get sessions with optional status filter
Future<List<SessionModel>> getSessions({SessionStatus? status})

// Get session details
Future<SessionModel> getSessionDetails(String sessionId)

// Join a session (required before voting/subscribing)
Future<void> joinSession(String sessionId)

// Leave a session
Future<void> leaveSession(String sessionId)

// Helper: Get only live sessions
Future<List<SessionModel>> getLiveSessions()
```

#### Admin Methods:
```dart
// Create a new session
Future<SessionModel> createSession(String name)

// Open a draft session (makes it LIVE)
Future<void> openSession(String sessionId)

// Pause an active session
Future<void> pauseSession(String sessionId)

// Close a session
Future<void> closeSession(String sessionId)

// Archive a closed session
Future<void> archiveSession(String sessionId)
```

### 3. Session Provider Updates (`lib/providers/session_provider.dart`)

Enhanced with real API integration:

```dart
// Load sessions with optional filter
await ref.read(sessionProvider.notifier).loadSessions(status: SessionStatus.live);

// Join a session
await ref.read(sessionProvider.notifier).joinSession(sessionId);

// Leave a session
await ref.read(sessionProvider.notifier).leaveSession(sessionId);

// Admin: Create session
await ref.read(sessionProvider.notifier).createSession("Session Name");

// Admin: Open session
await ref.read(sessionProvider.notifier).openSession(sessionId);

// Admin: Close session
await ref.read(sessionProvider.notifier).closeSession(sessionId);
```

**New Providers:**
- `liveSessionsProvider` - Filters and returns only live sessions
- `activeSessionProvider` - Returns the first live session (for quick access)

### 4. Member Home Screen Updates (`lib/features/member/home/screens/member_home_screen.dart`)

Added session join/leave functionality:

**Features:**
- ✅ Displays live sessions with join button
- ✅ Join session with one tap
- ✅ Leave session functionality
- ✅ Visual feedback (joined state)
- ✅ Loading states during join/leave
- ✅ Error handling with user-friendly messages
- ✅ Automatic session list refresh

**UI Components:**
- Beautiful join/leave button in session card
- Loading indicator while joining
- Success/error snackbar notifications
- Joined state tracking

### 5. API Constants (`lib/core/constants/api_constants.dart`)

Added all session endpoints:

```dart
static const String sessionsEndpoint = '/sessions';
static String sessionDetailsEndpoint(String sessionId) => '/sessions/$sessionId';
static String sessionJoinEndpoint(String sessionId) => '/sessions/$sessionId/join';
static String sessionLeaveEndpoint(String sessionId) => '/sessions/$sessionId/leave';
static String sessionOpenEndpoint(String sessionId) => '/sessions/$sessionId/open';
static String sessionPauseEndpoint(String sessionId) => '/sessions/$sessionId/pause';
static String sessionCloseEndpoint(String sessionId) => '/sessions/$sessionId/close';
static String sessionArchiveEndpoint(String sessionId) => '/sessions/$sessionId/archive';
```

### 6. Localization Updates

Added new strings:
- **English:**
  - `join_session`: "Join Session"
  - `leave_session`: "Leave Session"

- **Arabic:**
  - `join_session`: "الانضمام للجلسة"
  - `leave_session`: "مغادرة الجلسة"

## API Integration Details

### GET /sessions

**Query Parameters:**
- `status` (optional): LIVE, DRAFT, PAUSED, CLOSED, ARCHIVED

**Usage:**
```dart
// Get all sessions
final sessions = await sessionService.getSessions();

// Get only live sessions
final liveSessions = await sessionService.getSessions(status: SessionStatus.live);

// Get draft sessions
final drafts = await sessionService.getDraftSessions();
```

**Response:**
```json
[
  {
    "id": "session123",
    "name": "Morning Session",
    "status": "LIVE",
    "agendaText": "Budget discussion",
    "adminId": "admin456",
    "createdAt": "2025-10-17T08:00:00Z",
    "openedAt": "2025-10-17T09:00:00Z",
    "closedAt": null,
    "archivedAt": null
  }
]
```

### POST /sessions/{id}/join

**Description:** Join a session as an attendee. **Required** before:
- Subscribing to WebSocket `/topic/sessions/{id}`
- Voting on decisions
- Sending heartbeats
- Viewing session documents

**Usage:**
```dart
await sessionService.joinSession(sessionId);
```

**Response:** 200 OK or 201 Created

**Errors:**
- `403 FORBIDDEN` - No permission
- `409 CONFLICT` - Session not available (archived, etc.)

### POST /sessions/{id}/leave

**Description:** Leave a session

**Usage:**
```dart
await sessionService.leaveSession(sessionId);
```

**Response:** 200 OK or 204 No Content

### POST /sessions (Admin Only)

**Description:** Create a new draft session

**Request Body:**
```json
{
  "name": "Session Name"
}
```

**Usage:**
```dart
final session = await sessionService.createSession("Morning Session");
```

**Response:** Returns the created session object

### Session State Transitions (Admin)

```
   DRAFT
     ↓ (open)
   LIVE
     ↓ (pause)        ↓ (close)
  PAUSED  →  LIVE  →  CLOSED
                         ↓ (archive)
                      ARCHIVED
```

**Admin Actions:**
```dart
// Open a draft session (make it LIVE)
await sessionService.openSession(sessionId);

// Pause a live session
await sessionService.pauseSession(sessionId);

// Close a session
await sessionService.closeSession(sessionId);

// Archive a closed session
await sessionService.archiveSession(sessionId);
```

## User Flow: Member Joins Session

### Step-by-Step Flow:

```
1. Member opens home screen
   ↓
2. App calls GET /sessions?status=LIVE
   ↓
3. Live sessions displayed with "Join Session" button
   ↓
4. Member taps "Join Session"
   ↓
5. App calls POST /sessions/{id}/join
   ↓
6. Session added to joined sessions list
   ↓
7. Button changes to "Leave Session"
   ↓
8. Member can now:
   - Vote on decisions
   - View session documents
   - Participate in chat
   - Send WebSocket heartbeats
```

## Important Notes

### 🔴 **Critical: Join Before Other Actions**

According to the backend documentation, users **MUST** join a session before:

1. ✅ Subscribing to WebSocket `/topic/sessions/{id}`
2. ✅ Sending heartbeat messages
3. ✅ Voting on decisions
4. ✅ Viewing session documents

**Error if not joined:**
- WebSocket subscribe: `NOT_ATTENDEE` error on `/user/queue/errors`
- Voting: `403 NOT_ATTENDEE`
- Documents: May be restricted based on scope

### Session Status Filtering

**For Members:**
- Show only `LIVE` sessions
- Hide `DRAFT`, `PAUSED`, `CLOSED`, `ARCHIVED`

**For Admins:**
- Show all sessions
- Allow filtering by status
- Enable session state transitions

## Code Examples

### Display Live Sessions (Member)

```dart
// In member home screen
final liveSessions = ref.watch(liveSessionsProvider);

if (liveSessions.isEmpty) {
  return Text('No active sessions');
}

return ListView.builder(
  itemCount: liveSessions.length,
  itemBuilder: (context, index) {
    final session = liveSessions[index];
    return SessionCard(session: session);
  },
);
```

### Join Session (Member)

```dart
Future<void> _joinSession(String sessionId) async {
  try {
    await ref.read(sessionProvider.notifier).joinSession(sessionId);
    
    // Now can subscribe to WebSocket
    wsService.subscribeSession(sessionId);
    
    // Start sending heartbeats
    startHeartbeat(sessionId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined session successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to join: $e')),
    );
  }
}
```

### Create and Open Session (Admin)

```dart
Future<void> _createAndOpenSession(String name) async {
  try {
    // Create draft session
    await ref.read(sessionProvider.notifier).createSession(name);
    
    // Get the created session ID
    final sessions = await sessionService.getSessions(status: SessionStatus.draft);
    final newSession = sessions.first;
    
    // Open it (make it LIVE)
    await ref.read(sessionProvider.notifier).openSession(newSession.id);
    
    print('Session ${newSession.name} is now LIVE!');
  } catch (e) {
    print('Failed to create session: $e');
  }
}
```

### Filter Sessions by Status (Admin)

```dart
// Load only live sessions
await ref.read(sessionProvider.notifier).loadLiveSessions();

// Load only draft sessions
await ref.read(sessionProvider.notifier).loadDraftSessions();

// Load all sessions
await ref.read(sessionProvider.notifier).loadSessions();

// Load specific status
await ref.read(sessionProvider.notifier).loadSessions(status: SessionStatus.closed);
```

## Logging

All session operations are logged:

```
💡 SessionService: Fetching sessions with status: LIVE
💡 SessionService: Loaded 3 sessions
💡 SessionNotifier: Attempting to join session: session123
💡 SessionService: Successfully joined session: session123
💡 SessionNotifier: Successfully joined session
```

## Error Handling

### Common Errors

| Error Code | Scenario | Handling |
|------------|----------|----------|
| 403 | Not authorized to join | Show permission error |
| 404 | Session not found | Show not found error |
| 409 | Session archived/paused | Show conflict error |
| 401 | Not authenticated | Auto token refresh |

### Example Error Messages

```dart
// Permission error
"You do not have permission to join this session."

// Conflict error
"Session is not available for joining."

// Connection error
"Cannot connect to server. Please check your network connection."
```

## Testing

### Test Scenarios

#### 1. **View Live Sessions (Member)**
   - Login as member1
   - Open home screen
   - Expected: See all LIVE sessions

#### 2. **Join Session (Member)**
   - Click "Join Session" button
   - Expected: Success message, button changes to "Leave Session"

#### 3. **Leave Session (Member)**
   - Click "Leave Session" button
   - Expected: Success message, button changes to "Join Session"

#### 4. **Create Session (Admin)**
   - Login as admin
   - Navigate to sessions management
   - Create new session
   - Expected: Draft session created

#### 5. **Open Session (Admin)**
   - Select draft session
   - Click "Open" action
   - Expected: Session status changes to LIVE

## UI Updates

### Member Home Screen

**Before:**
- Shows all sessions (active and inactive)
- No join functionality

**After:**
- Shows only LIVE sessions
- Join/Leave button prominently displayed
- Visual feedback for joined state
- Loading states
- Error handling with snackbars

**Join Button:**
- **Not Joined:** White background, primary color text, login icon
- **Joined:** Transparent background, white text, logout icon
- **Loading:** Shows circular progress indicator

## Next Steps

Now that sessions are integrated, you can proceed with:

1. **WebSocket Integration**
   - Subscribe to `/topic/sessions/{id}` after joining
   - Send heartbeat messages
   - Receive real-time events

2. **Decisions/Voting Integration**
   - List decisions for joined session
   - Vote on open decisions
   - View voting results

3. **Agenda Integration**
   - View session agenda
   - Admin: Update agenda text/file

4. **Documents Integration**
   - View session documents
   - Upload documents
   - Download documents

## Session Lifecycle

### Member Perspective:

```
1. View live sessions on home screen
2. Join a session → POST /sessions/{id}/join
3. Participate in session:
   - View agenda
   - Vote on decisions
   - View documents
   - Chat with other members
   - Send heartbeats (keep active)
4. Leave session → POST /sessions/{id}/leave
```

### Admin Perspective:

```
1. Create session → POST /sessions (DRAFT)
2. Set up session:
   - Add agenda
   - Upload documents
   - Create decisions
3. Open session → POST /sessions/{id}/open (LIVE)
4. Manage during session:
   - Pause if needed
   - Monitor attendance
   - Open/close decisions
   - Manage speaking queue
5. Close session → POST /sessions/{id}/close
6. Archive → POST /sessions/{id}/archive
```

## Files Modified

```
Modified:
├── lib/models/session_model.dart              [Updated schema + enum]
├── lib/providers/session_provider.dart        [Real API integration]
├── lib/features/member/home/screens/member_home_screen.dart [Join/leave UI]
├── lib/core/constants/api_constants.dart      [Session endpoints]
└── lib/core/localization/app_localizations.dart [New strings]

Created:
├── lib/services/session_service.dart          [Session API service]
└── SESSION_INTEGRATION_GUIDE.md               [This file]
```

## Summary

✅ **Session listing** - Get sessions with status filtering  
✅ **Session details** - Get individual session information  
✅ **Join session** - Members can join live sessions  
✅ **Leave session** - Members can leave sessions  
✅ **Create session** - Admins can create draft sessions  
✅ **Session lifecycle** - Open, pause, close, archive  
✅ **Comprehensive logging** - All operations logged  
✅ **Error handling** - User-friendly error messages  
✅ **UI integration** - Beautiful join/leave button in member home  
✅ **Live filtering** - Members only see LIVE sessions  

The session management system is now fully functional and ready to use with your backend! 🚀


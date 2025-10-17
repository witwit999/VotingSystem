# Decisions & Voting Integration - Foundation Complete

## ✅ What's Been Implemented

### 1. **Decision Model** (`lib/models/decision_model.dart`)

Created comprehensive decision model matching backend schema:

```dart
enum DecisionStatus { open, closed }
enum VoteChoice { accept, deny, abstain }

class DecisionModel {
  final String id;
  final String sessionId;
  final String title;
  final String? description;
  final DecisionStatus status;
  final DateTime? openAt;
  final DateTime? closeAt;
  final bool allowRecast;
  final DecisionTally? tally;
}

class DecisionTally {
  final int accepted;
  final int denied;
  final int abstained;
  final int valid;        // accepted + denied
  final int activeBase;   // active attendees at close
}

class VoteModel {
  final String id;
  final String decisionId;
  final String userId;
  final VoteChoice choice;  // ACCEPT, DENY, ABSTAIN
  final DateTime castAt;
  final int seq;            // Monotonic counter
}
```

### 2. **Decision Service** (`lib/services/decision_service.dart`)

Complete API integration for decisions and voting:

#### Admin Methods:
```dart
// Create a decision in a session
Future<DecisionModel> createDecision({
  required String sessionId,
  required String title,
  String? description,
  bool allowRecast,
})

// Open decision for voting
Future<void> openDecision(String decisionId, DateTime closeAt)

// Close decision (end voting)
Future<void> closeDecision(String decisionId)
```

#### Member Methods:
```dart
// Get decisions for a session
Future<List<DecisionModel>> getSessionDecisions(String sessionId)

// Get decision details with tally
Future<DecisionModel> getDecisionDetails(String decisionId)

// Submit vote with automatic seq management
Future<VoteModel> submitVote({
  required String decisionId,
  required VoteChoice choice,
})

// Get all votes for a decision
Future<List<VoteModel>> getDecisionVotes(String decisionId)
```

### 3. **Decision Provider** (`lib/providers/decision_provider.dart`)

State management for decisions per session:

```dart
// Get decisions for a session (family provider)
ref.watch(sessionDecisionsProvider(sessionId))

// Get open decisions only
ref.watch(openDecisionsProvider(sessionId))

// Get active decision (first open decision)
ref.watch(activeDecisionProvider(sessionId))

// Actions
await ref.read(sessionDecisionsProvider(sessionId).notifier).createDecision(...)
await ref.read(sessionDecisionsProvider(sessionId).notifier).openDecision(...)
await ref.read(sessionDecisionsProvider(sessionId).notifier).closeDecision(...)
await ref.read(sessionDecisionsProvider(sessionId).notifier).submitVote(...)
```

### 4. **API Constants Updated**

Added decision endpoints:

```dart
static String sessionDecisionsEndpoint(String sessionId) =>
    '/sessions/$sessionId/decisions';
static String decisionDetailsEndpoint(String decisionId) =>
    '/decisions/$decisionId';
static String decisionOpenEndpoint(String decisionId) =>
    '/decisions/$decisionId/open';
static String decisionCloseEndpoint(String decisionId) =>
    '/decisions/$decisionId/close';
static String decisionVotesEndpoint(String decisionId) =>
    '/decisions/$decisionId/votes';
```

## 📊 **Backend API Schema**

### Create Decision:
```
POST /sessions/{id}/decisions
Body: {
  "title": "Budget Approval 2025",
  "description": "Vote on the proposed budget",
  "allowRecast": false
}
Response: Decision object
```

### Open Decision:
```
POST /decisions/{id}/open
Body: {
  "closeAt": "2025-10-17T18:00:00Z"
}
```

### Vote on Decision:
```
POST /decisions/{id}/votes
Body: {
  "choice": "ACCEPT",  // or "DENY", "ABSTAIN"
  "seq": 1            // Monotonic counter
}
```

### Decision Response Format:
```json
{
  "decision": {
    "id": "dec123",
    "sessionId": "session456",
    "title": "Budget Approval",
    "description": "Annual budget vote",
    "status": "OPEN",
    "openAt": "2025-10-17T10:00:00Z",
    "closeAt": "2025-10-17T18:00:00Z",
    "allowRecast": false
  },
  "tally": {
    "accepted": 45,
    "denied": 12,
    "abstained": 8,
    "valid": 57,
    "activeBase": 65
  }
}
```

## 🔑 **Key Features**

### Voting Mechanics:

1. **Sequence Numbers:**
   - Each vote has a `seq` (sequence) number
   - Monotonic counter per decision per user: 1, 2, 3...
   - Prevents duplicate votes and handles out-of-order delivery
   - Auto-managed by DecisionService

2. **Vote Choices:**
   - `ACCEPT` - Vote in favor
   - `DENY` - Vote against
   - `ABSTAIN` - Abstain from voting

3. **Recasting:**
   - If `allowRecast: true`, users can change their vote
   - New vote with higher `seq` replaces previous vote
   - If `false`, only first vote counts

4. **Tally Calculation:**
   - `valid = accepted + denied` (only accept/deny count as valid)
   - `passed = accepted > denied` (ties fail)
   - `activeBase` = active attendees (heartbeat within 30s) at close time
   - Percentages calculated against `activeBase`

### Decision Lifecycle:

```
1. CREATE (Admin)
   Admin creates decision in session
   ↓
   Status: Created (not voting yet)

2. OPEN (Admin)
   Admin opens decision with closeAt time
   ↓
   Status: OPEN
   ↓
   Members can vote
   ↓
   Live tally updates (via WebSocket)

3. CLOSE (Admin or Auto-close at closeAt)
   Decision closed
   ↓
   Status: CLOSED
   ↓
   Final tally calculated
   ↓
   Result: PASSED or FAILED
```

## 🎯 **Integration Points**

### Per-Session Decisions:

**Admin can:**
1. View all decisions for a session
2. Create new decision in session
3. Open decision with end time
4. Close decision manually
5. View real-time voting results

**Members can:**
1. View open decisions in joined session
2. Vote (ACCEPT/DENY/ABSTAIN)
3. Change vote if `allowRecast` is true
4. View live tally while voting
5. See final results after close

## 🚀 **Next Steps to Complete**

### UI Implementation Needed:

1. **Admin - Create Decision Dialog**
   - Add "New Decision" button in session details
   - Form: title, description, allowRecast checkbox
   - Create as draft first

2. **Admin - Decision Management**
   - List decisions within session card/details
   - Open decision button with time picker
   - Close decision button
   - View live tallies

3. **Member - View Decisions**
   - Show open decisions in session
   - Display decision question
   - Vote buttons (Accept/Deny/Abstain)
   - Live results while voting

4. **Member - Submit Vote**
   - Vote confirmation dialog
   - Submit with auto seq management
   - Show success/error feedback
   - Update to show "Voted" status

### WebSocket Integration (For Live Updates):

```
Subscribe to: /topic/sessions/{sessionId}

Events to handle:
- decision.opened → Show new decision
- vote.tally → Update live results
- decision.closed → Show final results
```

## 📁 **Files Created**

```
Created:
├── lib/models/decision_model.dart        [Decision, Tally, Vote models]
├── lib/services/decision_service.dart    [Complete decision API]
├── lib/providers/decision_provider.dart  [Decision state management]
└── DECISIONS_VOTING_FOUNDATION.md        [This file]
```

## 📋 **API Endpoints Available**

| Method | Endpoint | Purpose | Who |
|--------|----------|---------|-----|
| POST | `/sessions/{id}/decisions` | Create decision | Admin |
| GET | `/sessions/{id}/decisions` | List decisions | All (if joined) |
| GET | `/decisions/{id}` | Get decision + tally | All (if joined) |
| POST | `/decisions/{id}/open` | Open for voting | Admin |
| POST | `/decisions/{id}/close` | Close voting | Admin |
| POST | `/decisions/{id}/votes` | Submit vote | Member |
| GET | `/decisions/{id}/votes` | Get all votes | Session members |

## 🎨 **Suggested UI Flow**

### Admin Session Management:

```
Sessions Screen
  ↓ Click session card
Session Details Screen
  ├── Session info
  ├── [Decisions List]
  │   ├── Decision 1 [OPEN]   [Close Decision]
  │   ├── Decision 2 [CLOSED] [View Results]
  │   └── [+ New Decision Button]
  │       ↓ Click
  │   Create Decision Dialog
  │   ├── Title
  │   ├── Description
  │   ├── ☑ Allow Recast
  │   └── [Create] [Cancel]
  │       ↓ Created
  │   Decision appears in list
  │   [Open Decision Button]
  │       ↓ Click
  │   Select End Time
  │       ↓ Confirm
  │   Decision opened (status: OPEN)
  │   Members can vote
  │
  └── [Manage other session features]
```

### Member Voting Flow:

```
Member Home
  ↓ Join Session
Session Joined
  ↓ Navigate to Voting
Voting Screen (for current session)
  ├── Decision 1: Budget Approval [OPEN]
  │   ├── "Do you approve the budget?"
  │   ├── [✓ Accept]  [✗ Deny]  [− Abstain]
  │   └── Live Results:
  │       Accept: 45 (69%)
  │       Deny: 12 (18%)
  │       Abstain: 8 (12%)
  │
  ├── Decision 2: Healthcare Reform [CLOSED]
  │   └── Final Results:
  │       Accept: 52 (70%) → PASSED
  │
  └── No more open decisions
```

## 💡 **Important Backend Rules**

### Must Join Session First:
```
Before voting, member must:
1. POST /sessions/{id}/join
2. Subscribe to WebSocket /topic/sessions/{id}
3. Send periodic heartbeats

If not joined:
- GET /sessions/{id}/decisions → 403 NOT_ATTENDEE
- POST /decisions/{id}/votes → 403 NOT_ATTENDEE
```

### Sequence Numbers:
```
- Each vote needs incremental seq: 1, 2, 3, 4...
- Reusing old seq is ignored (idempotency)
- DecisionService auto-manages seq per decision
```

### Session State:
```
- If session PAUSED → Voting returns 409 SESSION_PAUSED
- If session ARCHIVED → Voting returns 409 SESSION_ARCHIVED
```

## 🧪 **Testing Guide**

### Test Case: Complete Decision Flow

**As Admin:**
```
1. Login as admin
2. Go to Sessions Management
3. Create new session: "Test Session"
4. Open session (make it LIVE)
5. Create decision: "Approve Budget"
6. Open decision (set closeAt to 1 hour from now)
7. Decision is now OPEN
```

**As Member:**
```
1. Login as member1
2. Home screen shows "Test Session"
3. Join the session
4. Go to Voting screen
5. See "Approve Budget" decision
6. Vote: ACCEPT
7. See live tally update
8. Vote recorded with seq=1
```

**As Admin (close):**
```
1. Return to session
2. Close decision
3. Final tally calculated
4. Result: PASSED or FAILED
```

## 📊 **Current Integration Status**

### ✅ Completed:
- [x] Decision model (backend-aligned)
- [x] Decision service (all API methods)
- [x] Decision provider (state management)
- [x] Vote sequence management
- [x] API endpoints configuration
- [x] Comprehensive logging
- [x] Error handling

### 🚧 Next Steps:
- [ ] Admin: Create decision UI in session
- [ ] Admin: List decisions in session
- [ ] Admin: Open/close decision buttons
- [ ] Member: View decisions in session
- [ ] Member: Vote UI (Accept/Deny/Abstain)
- [ ] Real-time tally updates (WebSocket)
- [ ] Vote confirmation dialog
- [ ] Results display

## 📝 **Summary**

**Foundation is complete!** The backend integration for decisions and voting is ready:

- ✅ Decision models match backend schema
- ✅ All API methods implemented
- ✅ State management configured
- ✅ Sequence counter auto-managed
- ✅ Error handling comprehensive
- ✅ Logging throughout

**Next:** Implement the UI components to allow admins to create decisions and members to vote.

---

**Total Endpoints Integrated So Far: 17**
- ✅ Auth: 3/3
- ✅ Sessions: 9/9
- ✅ Decisions: 5/6 (foundation ready)


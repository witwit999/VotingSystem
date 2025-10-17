# Member Home Screen - Decision Model Migration Fix

## Error

```
NoSuchMethodError: Class 'DecisionModel' has no instance getter 'isActive'.
Receiver: Instance of 'DecisionModel'
Tried calling: isActive
```

## Root Cause

The `member_home_screen.dart` was still using old `VotingModel` fields:
- ❌ `voting.isActive` → doesn't exist on `DecisionModel`
- ❌ `voting.question` → doesn't exist on `DecisionModel`
- ❌ `voting.endTime` → doesn't exist on `DecisionModel`
- ❌ `voting.userVote` → doesn't exist on `DecisionModel`

## DecisionModel vs VotingModel

### Old VotingModel (deprecated)
```dart
class VotingModel {
  final String title;
  final String question;  ❌
  final DateTime endTime; ❌
  final bool isActive;    ❌
  final String? userVote; ❌
  final VotingResults results;
}
```

### New DecisionModel (backend-integrated)
```dart
class DecisionModel {
  final String title;         ✅
  final String? description;  ✅ (replaces question)
  final DateTime? closeAt;    ✅ (replaces endTime)
  final DecisionStatus status; ✅
  final DecisionTally? tally; ✅
  
  bool get isOpen => status == DecisionStatus.open; ✅ (replaces isActive)
  bool get isClosed => status == DecisionStatus.closed; ✅
}
```

## Fixes Applied

### 1. Changed Field References

**Line 454:**
```dart
// Before:
if (voting == null || !voting.isActive)

// After:
if (voting == null || !voting.isOpen)
```

**Lines 486-487:**
```dart
// Before:
voting.endTime != null && DateTime.now().isAfter(voting.endTime!)

// After:
voting.closeAt != null && DateTime.now().isAfter(voting.closeAt!)
```

**Line 536:**
```dart
// Before:
Text(voting.question)

// After:
if (voting.description != null && voting.description!.isNotEmpty) ...[
  Text(voting.description!)
]
```

**Line 612:**
```dart
// Before:
_VotingTimerWhite(endTime: voting.endTime!, l10n: l10n)

// After:
_VotingTimerWhite(endTime: voting.closeAt!, l10n: l10n)
```

### 2. Removed Dead Code

**Removed `hasVoted` variable:**
```dart
// Before:
final hasVoted = voting.userVote != null;

// After:
// Removed - userVote tracking requires separate API call
```

**Simplified button logic:**
```dart
// Before (with hasVoted):
Icon(isExpired ? Icons.block : hasVoted ? Icons.poll : Icons.how_to_vote)
Text(isExpired ? 'Voting Ended' : hasVoted ? 'Voting Results' : 'Vote Now')

// After (simplified):
Icon(isExpired ? Icons.block : Icons.how_to_vote)
Text(isExpired ? 'Voting Ended' : 'Vote Now')
```

## Vote Tracking (Future Enhancement)

To track if a user has voted, you would need to:

### Option 1: Add to DecisionModel
```dart
// Fetch decision with user's vote info
GET /decisions/{id}?includeUserVote=true

// Response:
{
  "decision": {...},
  "tally": {...},
  "userVote": {
    "choice": "ACCEPT",
    "castAt": "..."
  }
}
```

### Option 2: Separate API Call
```dart
// Get current user's vote for a decision
GET /decisions/{id}/votes/me

// Response:
{
  "id": "...",
  "choice": "ACCEPT",
  "castAt": "...",
  "seq": 1
}
```

### Option 3: Client-Side Tracking
```dart
// Store in local state/cache
final votedDecisions = ref.watch(votedDecisionsProvider);
final hasVoted = votedDecisions.contains(decision.id);
```

For now, we simplified the UI to not show vote status on the home screen.

## UI Changes

### Before (with hasVoted)
```
┌─────────────────────────────┐
│ Active Decision             │
│ ───────────────────────────│
│ Approve Budget 2025         │
│ Vote to approve the budget  │
│                             │
│ ✓ Vote Submitted            │  ← Removed
│                             │
│ [Voting Results] button     │  ← Removed
└─────────────────────────────┘
```

### After (simplified)
```
┌─────────────────────────────┐
│ Active Decision             │
│ ───────────────────────────│
│ Approve Budget 2025         │
│ Vote to approve the budget  │
│                             │
│ ⏱ Time Remaining: 4:23      │
│                             │
│ [Vote Now] button           │
└─────────────────────────────┘
```

Or if expired:
```
┌─────────────────────────────┐
│ Active Decision             │
│ ───────────────────────────│
│ Approve Budget 2025         │
│ Vote to approve the budget  │
│                             │
│ ⏱ Voting Ended              │
│                             │
│ [Voting Ended] (disabled)   │
└─────────────────────────────┘
```

## Files Modified

✅ `lib/features/member/home/screens/member_home_screen.dart`
  - Line 454: Changed `isActive` → `isOpen`
  - Lines 485-490: Removed `hasVoted`, updated `endTime` → `closeAt`
  - Lines 533-545: Changed `question` → `description` with null check
  - Line 578: Changed `endTime` → `closeAt`
  - Lines 626-656: Simplified button logic (removed hasVoted conditions)

## Testing

### Test the Fixed Screen

1. **Hot restart the app** (Cmd+Shift+F5)

2. **As Admin:**
   - Create a session (make it LIVE)
   - Create a decision
   - Open the decision (5-minute timer starts)

3. **As Member:**
   - Log in and go to Home screen
   - ✅ Should see "Active Decision" section
   - ✅ Shows decision title
   - ✅ Shows description (if provided)
   - ✅ Shows countdown timer
   - ✅ "Vote Now" button is clickable
   - Click "Vote Now" → goes to Voting screen

4. **After 5 minutes:**
   - ✅ Timer shows "Voting Ended"
   - ✅ Button is disabled
   - ✅ No crash!

## Summary of Changes

| Old Field (VotingModel) | New Field (DecisionModel) | Notes |
|------------------------|---------------------------|-------|
| `isActive`             | `isOpen`                  | Property name change |
| `question`             | `description`             | Property name change + nullable |
| `endTime`              | `closeAt`                 | Property name change |
| `userVote`             | *(removed)*               | Requires separate API call |
| `results`              | `tally`                   | Property name + structure change |

---
**Fix Date:** October 17, 2025  
**Status:** ✅ Complete  
**Linter Errors:** 0  
**Migration:** VotingModel → DecisionModel complete


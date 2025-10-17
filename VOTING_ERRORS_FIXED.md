# Voting System Errors Fixed

## Summary
Fixed all linter errors in `reports_screen.dart` and `voting_screen.dart` after backend integration changes to the voting system.

## Issues Fixed

### 1. voting_screen.dart

#### Issue 1: Wrong provider type access
**Error:** `The method 'whenData' isn't defined for the type 'List'.`

**Root Cause:** 
- `liveSessionsProvider` returns `List<SessionModel>` directly, not `AsyncValue<List<SessionModel>>`
- Code was trying to use `.whenData()` method which doesn't exist on `List`

**Fix:**
```dart
// Before (incorrect):
final sessions = ref.read(liveSessionsProvider);
sessions.whenData((sessionList) {
  // ...
});

// After (correct):
final sessions = ref.read(liveSessionsProvider);
if (sessions.isNotEmpty) {
  // Direct access to list
}
```

#### Issue 2: Wrong method signature for submitVote
**Error:** `The named parameter 'decisionId' isn't defined.`

**Root Cause:**
- `SessionDecisionsNotifier.submitVote()` expects positional parameters
- Code was passing named parameters

**Fix:**
```dart
// Before (incorrect):
await ref.read(sessionDecisionsProvider(_joinedSessionId!).notifier)
    .submitVote(decisionId: decisionId, choice: choice);

// After (correct):
await ref.read(sessionDecisionsProvider(_joinedSessionId!).notifier)
    .submitVote(decisionId, choice);
```

### 2. reports_screen.dart

#### Issue 1: Wrong provider type
**Error:** `The method 'when' isn't defined for the type 'List'.`

**Root Cause:**
- `votingHistoryProvider` was changed from `FutureProvider` to regular `Provider<List<DecisionModel>>`
- Returns a simple list, not an `AsyncValue`
- Code was using `.when()` method expecting an `AsyncValue`

**Fix:**
```dart
// Before (incorrect):
votingHistory.when(
  data: (history) { /* ... */ },
  loading: () { /* ... */ },
  error: (error, _) { /* ... */ },
)

// After (correct):
votingHistory.isEmpty
    ? _buildEmptyState(l10n)
    : Column(
        children: List.generate(votingHistory.length, (index) {
          return _buildVotingCard(votingHistory[index], index, l10n);
        }),
      )
```

#### Issue 2: Model type change from VotingModel to DecisionModel
**Problem:**
- Reports screen was using old `VotingModel` with fields like `yes`, `no`, `abstain`
- Now uses `DecisionModel` with `DecisionTally` containing `accepted`, `denied`, `abstained`

**Fix:**
1. Added import: `import '../../../../models/decision_model.dart';`

2. Updated `_buildVotingCard` signature:
```dart
// Before:
Widget _buildVotingCard(dynamic voting, int index, AppLocalizations l10n)

// After:
Widget _buildVotingCard(DecisionModel decision, int index, AppLocalizations l10n)
```

3. Updated field access:
```dart
// Before:
voting.results.yes
voting.results.no
voting.results.abstain
voting.results.yesPercentage
voting.results.noPercentage
voting.results.abstainPercentage
voting.results.total

// After:
final accepted = decision.tally?.accepted ?? 0;
final denied = decision.tally?.denied ?? 0;
final abstained = decision.tally?.abstained ?? 0;
final total = accepted + denied + abstained;
final acceptPercentage = decision.tally?.acceptPercentage ?? 0;
final denyPercentage = decision.tally?.denyPercentage ?? 0;
final abstainPercentage = decision.tally?.abstainPercentage ?? 0;
```

4. Updated labels to match backend terminology:
```dart
// Before:
l10n.yes.toUpperCase()
l10n.no.toUpperCase()

// After:
l10n.accepted.toUpperCase()
l10n.denied.toUpperCase()
```

## Files Modified

### 1. `/lib/features/member/voting/screens/voting_screen.dart`
**Changes:**
- Fixed `liveSessionsProvider` access (removed `.whenData()`)
- Fixed `submitVote` method call to use positional parameters
- Added `await` to `loadDecisions()` call for better async flow

**Line Changes:**
- Lines 33-61: Fixed session loading logic
- Line 482: Fixed submitVote call

### 2. `/lib/features/admin/reports/screens/reports_screen.dart`
**Changes:**
- Added `DecisionModel` import
- Changed provider access from `.when()` to direct list access
- Updated `_buildVotingCard` to use `DecisionModel` instead of `VotingModel`
- Updated field names from yes/no/abstain to accepted/denied/abstained
- Added null-safety checks for `decision.tally`

**Line Changes:**
- Line 9: Added DecisionModel import
- Lines 83-95: Simplified voting history rendering
- Lines 279-463: Complete rewrite of `_buildVotingCard` method

## Testing Recommendations

### For voting_screen.dart:
1. Open the member voting screen
2. Verify it loads the active session correctly
3. Submit a test vote (ACCEPT, DENY, or ABSTAIN)
4. Verify vote submission works without errors
5. Check that live results display properly

### For reports_screen.dart:
1. Open the admin reports screen
2. Verify voting history displays closed decisions
3. Check that vote counts show as ACCEPTED, DENIED, ABSTAINED
4. Verify percentages are calculated correctly
5. Ensure no crashes when decisions have no votes (null tally)

## Verification

✅ **All linter errors resolved**
✅ **Type safety maintained**
✅ **Null safety properly handled**
✅ **Backend integration preserved**
✅ **UI labels updated to match backend schema**

## Related Changes

These fixes are part of the larger backend integration effort:
- `DecisionModel` now replaces legacy `VotingModel`
- `DecisionTally` uses `accepted/denied/abstained` instead of `yes/no/abstain`
- Providers simplified to use direct data access where appropriate

---
**Fix Date:** October 17, 2025
**Status:** ✅ Complete
**Linter Errors:** 0


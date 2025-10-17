# Decision "Open" 400 Error - Troubleshooting Guide

## Error

```
Status: 400
Message: Malformed JSON request
Endpoint: POST /decisions/{id}/open
```

## Backend Expectation

According to `Backend_reference.md`:

```
POST /decisions/{dId}/open (ADMIN) { closeAt: ISO-8601 }
```

Example ISO-8601 format:
```
"2025-10-17T22:00:00Z"     ✅ UTC with Z
"2025-10-17T22:00:00.000Z" ✅ UTC with milliseconds
"2025-10-17T15:00:00-07:00" ✅ With timezone offset
```

## Current Implementation

### What We're Sending

```dart
final closeAtString = closeAt.toUtc().toIso8601String();
final requestBody = {'closeAt': closeAtString};

// Example output:
// closeAtString = "2025-10-17T22:00:00.000Z"
// requestBody = {'closeAt': '2025-10-17T22:00:00.000Z'}
```

### Dio POST Request

```dart
await _apiService.post(
  '/decisions/{id}/open',
  data: {'closeAt': closeAtString},
);
```

Dio automatically:
- ✅ Serializes Map to JSON
- ✅ Sets `Content-Type: application/json`
- ✅ Encodes as `{"closeAt":"2025-10-17T22:00:00.000Z"}`

## Enhanced Logging

I've added detailed logging to help diagnose the issue:

```dart
AppLogger.debug('DecisionService: closeAt (UTC): $closeAtString');
AppLogger.debug('DecisionService: closeAt (local): ${closeAt.toIso8601String()}');
AppLogger.debug('DecisionService: Request body: $requestBody');
AppLogger.error('  - Response data: ${e.response?.data}');
AppLogger.error('  - Status code: ${e.response?.statusCode}');
```

## Testing Steps

### Step 1: Try Opening a Decision Again

1. Hot restart the app (Cmd+Shift+F5)
2. Create a new decision
3. Try to open it
4. **Check the console output** for:
   ```
   DecisionService: closeAt (UTC): [TIMESTAMP]
   DecisionService: Request body: [DATA]
   Response data: [ERROR DETAILS]
   ```

### Step 2: Check Backend Logs

Check your backend console for more specific error details about why it rejected the request.

## Possible Issues & Solutions

### Issue 1: DateTime Format Mismatch

**Symptom:** Backend expects different ISO-8601 variant

**Solutions to try:**

**Option A: Use milliseconds since epoch (if backend accepts Long)**
```dart
// In decision_service.dart, line 155:
final requestBody = {'closeAt': closeAt.millisecondsSinceEpoch};
```

**Option B: Use specific format without milliseconds**
```dart
final closeAtString = closeAt.toUtc().toIso8601String().split('.')[0] + 'Z';
// Result: "2025-10-17T22:00:00Z" (no milliseconds)
```

**Option C: Use custom format**
```dart
import 'package:intl/intl.dart';

final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
final closeAtString = formatter.format(closeAt.toUtc());
```

### Issue 2: Empty or Null Body

**Check:** Backend might reject empty additional fields

**Current:**
```dart
data: {'closeAt': closeAtString}
```

**Try:**
```dart
data: {'closeAt': closeAtString, 'allowRecast': widget.decision.allowRecast}
```

### Issue 3: Content-Type Issue

**Check:** Dio might not be sending correct headers

**Try adding explicit options:**
```dart
await _apiService.post(
  ApiConstants.decisionOpenEndpoint(decisionId),
  data: requestBody,
  options: Options(
    contentType: 'application/json',
    validateStatus: (status) => status! < 500,
  ),
);
```

### Issue 4: Backend Validation

**Check:** Backend might validate:
- ✅ closeAt must be in the future
- ✅ Session must be LIVE
- ✅ Decision must be CLOSED
- ✅ Admin must have permission

## Recommended Next Steps

### 1. Check the Enhanced Logs

After hot restart, try opening a decision and look for:
```
[D] DecisionService: closeAt (UTC): 2025-10-17T22:30:00.000Z
[D] DecisionService: Request body: {closeAt: 2025-10-17T22:30:00.000Z}
[E] - Response data: {timestamp: ..., code: ..., message: ...}
```

The response data will tell us exactly what the backend doesn't like.

### 2. Test with Backend API Directly

Use curl or Postman to test:

```bash
curl -X POST http://192.168.1.110:8080/decisions/{decisionId}/open \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"closeAt":"2025-10-17T22:00:00Z"}'
```

If this works, we know the format is correct and there's something in our Dart code.

### 3. Check Backend Swagger Docs

Visit: `http://192.168.1.110:8080/swagger-ui`

Look for the `/decisions/{id}/open` endpoint and check:
- Expected request body schema
- Required fields
- DateTime format examples

## Quick Test: Alternative Approach

If the issue persists, we can try using the backend's epoch milliseconds approach (from the WebSocket heartbeat example in Backend_reference.md):

```dart
// In decision_service.dart:
final closeAtEpoch = closeAt.millisecondsSinceEpoch;
AppLogger.debug('DecisionService: closeAt epoch: $closeAtEpoch');

final response = await _apiService.post(
  ApiConstants.decisionOpenEndpoint(decisionId),
  data: {'closeAt': closeAtEpoch}, // Send as number instead of string
);
```

## Expected Backend Response

### Success (200 or 204):
```json
// No body OR
{
  "decision": {
    "id": "...",
    "status": "OPEN",
    "openAt": "2025-10-17T21:00:00Z",
    "closeAt": "2025-10-17T22:00:00Z"
  }
}
```

### Error (400):
```json
{
  "timestamp": "2025-10-17T21:18:58Z",
  "path": "/decisions/68f2888adda4a2fe797fd035/open",
  "code": "VALIDATION_ERROR",
  "message": "[Specific error about what's wrong]"
}
```

## Files Modified for Enhanced Logging

✅ `lib/services/decision_service.dart`
  - Added detailed logging for closeAt timestamp
  - Shows both UTC and local time formats
  - Logs full request body
  - Logs full error response

## Next Actions

1. **Hot restart the app** (Cmd+Shift+F5)
2. **Try opening a decision** and check console
3. **Share the new log output** with the detailed closeAt and response data
4. **Check backend logs** for the actual validation error

The enhanced logging will tell us exactly what the backend doesn't like about the request!

---
**Investigation Date:** October 17, 2025  
**Status:** 🔍 Investigating  
**Enhanced Logging:** ✅ Added


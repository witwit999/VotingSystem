# Unauthorized Error - Debug Guide

## Issue

Getting "Unauthorized" error when fetching sessions, even though login succeeded.

## Enhanced Logging Added

I've added comprehensive logging to help identify the issue. After hot restarting, you'll see detailed logs that will tell us exactly what's wrong.

## What to Check in Logs

### 1. **Check if Token is Being Loaded**

Look for these logs when loading sessions:

```
🐛 ApiService: Request to /sessions without token
```
**OR**
```
🐛 ApiService: Using cached access token
🐛 ApiService: Request to /sessions with Bearer token
```

**If you see "without token":**
- ❌ Token is not being loaded
- Problem: Token not in SharedPreferences or not being retrieved

**If you see "with Bearer token":**
- ✅ Token is being sent
- Problem: Token might be invalid or expired

### 2. **Check Token Storage After Login**

After successful login, look for:
```
💡 AuthService: Login completed successfully for user: admin (ADMIN)
🐛 ApiService: Loaded access token from storage
🐛 ApiService: Token preview: eyJhbGciOiJSUzI1NiI...
```

### 3. **Check Sessions Request**

When loading sessions, look for:
```
💡 MemberHomeScreen: Loading sessions on screen init
💡 SessionService: Fetching sessions
🐛 SessionService: Endpoint: http://192.168.1.110:8080/sessions
❌ SessionService: Failed to fetch sessions
   - Error type: DioExceptionType.badResponse
   - Status code: 401
   - Response data: {error details}
   - Request URL: http://192.168.1.110:8080/sessions
   - Request headers: {Authorization: Bearer ...}
```

## Possible Causes & Solutions

### Cause 1: Token Not Being Sent

**Symptoms:**
```
🐛 ApiService: Request to /sessions without token
❌ Status code: 401
```

**Solution:**
The ApiService might not be reading the token from SharedPreferences correctly.

**Debug Steps:**
1. After login, manually check if token was saved:
   ```dart
   final prefs = await SharedPreferences.getInstance();
   final token = prefs.getString('access_token');
   print('Stored token: $token');
   ```

2. If token is null, the issue is in `auth_service.dart` `_saveTokens()` method

### Cause 2: Token Expired

**Symptoms:**
```
🐛 ApiService: Request to /sessions with Bearer token
❌ Status code: 401
💡 ApiService: Received 401, attempting token refresh
```

**Solution:**
- Token expired (15 min TTL)
- Token refresh should happen automatically
- Check if refresh token is valid

**Debug:**
- Login again to get fresh tokens
- Try immediately after login

### Cause 3: Backend Requires Different Token Format

**Symptoms:**
```
❌ Status code: 401
   - Request headers: {Authorization: Bearer eyJ...}
```

**Solution:**
- Verify backend expects `Authorization: Bearer <token>` header
- Check backend logs to see what it's receiving

**Test in Postman:**
```bash
# Copy the token from logs and test manually
curl http://192.168.1.110:8080/sessions \
  -H "Authorization: Bearer <YOUR_TOKEN_HERE>"
```

### Cause 4: Backend Session Endpoint Requires Special Permission

**Symptoms:**
```
❌ Status code: 401
   - Response data: {"code":"FORBIDDEN", "message":"..."}
```

**Solution:**
- Backend might have special permissions for /sessions endpoint
- Check backend logs
- Verify user has correct role

## Quick Fixes

### Fix 1: Restart App After Login

Sometimes the token needs a full app restart to propagate:

1. Login successfully
2. Stop the app completely (not just hot restart)
3. Run the app again: `flutter run`
4. Check if sessions load

### Fix 2: Clear App Data

Clear all stored data and login fresh:

```dart
// Temporarily add this to logout or in debug menu
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
AppLogger.info('All app data cleared');
```

Then:
1. Restart app
2. Login again
3. Try loading sessions

### Fix 3: Verify Token is Valid

Add temporary debug code to check token:

```dart
// In session_service.dart, add before making request:
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('access_token');
AppLogger.debug('DEBUG: Token in storage: ${token?.substring(0, 20)}...');
```

## Step-by-Step Debug Process

### Step 1: Login
```
1. Enter credentials
2. Tap login
3. Look for: "Login completed successfully"
4. Note the token preview in logs
```

### Step 2: Navigate to Home
```
1. After login, home screen loads
2. Look for: "Loading sessions on screen init"
3. Look for: "Request to /sessions"
4. Check if "with Bearer token" or "without token"
```

### Step 3: Check Error Details
```
If 401 error:
1. Copy the full error log
2. Check "Request headers" - should have Authorization
3. Check "Response data" - backend error message
4. Check "Request URL" - should be correct endpoint
```

### Step 4: Share Logs

Share these specific log lines:
```
1. Login success log with token preview
2. Session request log (with/without token)
3. Error log with all details
4. Request headers from error log
```

## Expected Successful Flow

When everything works correctly, you should see:

```
💡 Login attempt for user: admin
💡 AuthService: Login completed successfully for user: admin (ADMIN)
🐛 ApiService: Loaded access token from storage
🐛 ApiService: Token preview: eyJhbGciOiJSUzI1Ni...

💡 MemberHomeScreen: Loading sessions on screen init
💡 SessionService: Fetching sessions
🐛 ApiService: Using cached access token
🐛 ApiService: Request to /sessions with Bearer token
🐛 SessionService: Response status: 200
🐛 SessionService: Sessions received successfully
🐛 SessionService: Response data: [{...}]
💡 SessionService: Loaded 3 sessions
```

## Backend Verification

Test if backend accepts your token:

```bash
# 1. Login via curl to get token
TOKEN=$(curl -X POST http://192.168.1.110:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' \
  | jq -r '.accessToken')

echo "Token: $TOKEN"

# 2. Test sessions endpoint with token
curl http://192.168.1.110:8080/sessions \
  -H "Authorization: Bearer $TOKEN" \
  -v
```

Expected: 200 OK with sessions array

## Next Steps

1. **Hot restart** app (Press `R`)
2. **Login** with member1
3. **Watch the logs** carefully
4. **Copy and share:**
   - Token loading logs
   - Session request logs
   - Error details
5. I'll help diagnose the exact issue!

The enhanced logging will tell us exactly what's happening! 🔍


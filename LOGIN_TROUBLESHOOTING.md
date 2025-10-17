# Login Troubleshooting Guide

## Enhanced Debug Logging Added

I've added comprehensive debug logging to help identify the login issue. The logs will now show:

### What You'll See in Logs

1. **Request Details:**
   ```
   💡 AuthService: Attempting login for username: admin
   🐛 AuthService: API endpoint: http://192.168.1.100:8080/auth/login
   🐛 AuthService: Request body: {"username": "admin", "password": "***"}
   ```

2. **Response Details (if successful):**
   ```
   🐛 AuthService: Login response received with status 200
   🐛 AuthService: Response data: {full response here}
   🐛 AuthService: Response keys: [accessToken, refreshToken, user]
   ```

3. **Error Details (if failed):**
   ```
   ❌ AuthService: Login failed with DioException
      - Error type: DioExceptionType.connectionError
      - Status code: null
      - Response data: null
      - Error message: Connection refused
      - Network issue: Cannot connect to http://192.168.1.100:8080
   ```

## Common Issues & Solutions

### Issue 1: Connection Refused / Cannot Connect

**Symptoms:**
- Error: "Cannot connect to server"
- Error type: `connectionError` or `connectionTimeout`

**Solutions:**

1. **Check Backend is Running:**
   ```bash
   # Verify backend is running on port 8080
   curl http://localhost:8080/auth/login -X POST \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"admin123"}'
   ```

2. **Verify IP Address:**
   - **Android Emulator**: Use `http://10.0.2.2:8080` (special alias for host's localhost)
   - **Physical Device**: Use your PC's LAN IP (e.g., `http://192.168.1.100:8080`)
   - **iOS Simulator**: Use `http://localhost:8080` or your PC's LAN IP

3. **Current Configuration:**
   ```dart
   // In lib/core/constants/api_constants.dart
   static const String baseUrl = 'http://192.168.1.100:8080';
   ```

4. **Test Connection:**
   ```bash
   # From your device/emulator, test if backend is reachable
   # For Android Emulator:
   adb shell ping 10.0.2.2
   
   # For Physical Device:
   ping 192.168.1.100
   ```

### Issue 2: Response Parsing Error

**Symptoms:**
- Log shows: "Missing required fields in response"
- Error: "Invalid response format from server"

**Cause:** Backend response format doesn't match expected format.

**Expected Response Format:**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "user": {
    "id": "123",
    "username": "admin",
    "displayName": "Admin User",
    "role": "ADMIN"
  }
}
```

**Solution:**
Check the logs for actual response:
```
🐛 AuthService: Response data: {actual response here}
🐛 AuthService: Response keys: [actual keys here]
```

If keys are different (e.g., `access_token` instead of `accessToken`), you'll need to update the parsing logic.

### Issue 3: 401 Unauthorized

**Symptoms:**
- Status code: 401
- Error: "Invalid username or password"

**Solutions:**
1. Verify credentials are correct
2. Check backend seed data is initialized
3. Verify backend authentication is working in Postman

### Issue 4: CORS Error (Web Only)

**Symptoms:**
- CORS policy error in browser console

**Solution:**
Backend needs to enable CORS for your frontend URL.

## Current Configuration Check

### 1. Check Base URL
Open `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://192.168.1.100:8080';  // ← Your current setting
```

**For Android Emulator, change to:**
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

**For Physical Device:**
```dart
// Find your PC's IP address:
// - Windows: ipconfig
// - Mac/Linux: ifconfig or ip addr

static const String baseUrl = 'http://YOUR_PC_IP:8080';
```

### 2. Verify Backend is Running

**Test in Postman:**
```
POST http://localhost:8080/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

**Test from Terminal:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' \
  -v
```

### 3. Check Firewall

Ensure port 8080 is not blocked:
```bash
# Mac
sudo lsof -i :8080

# Windows
netstat -ano | findstr :8080

# Linux
sudo netstat -tulpn | grep :8080
```

## Step-by-Step Debugging

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Try to Login
Use credentials: `admin` / `admin123`

### Step 3: Check Logs
Look for the sequence:
1. ✅ "Attempting login for username: admin"
2. ✅ "API endpoint: http://..."
3. ✅ "Request to /auth/login without token"
4. ❓ What happens next?

### Step 4: Identify the Issue

**If you see:**
- "Cannot connect to server" → Network/connection issue
- "Login response received with status 200" → Check response parsing
- "Login failed with status code: 401" → Credentials issue
- "Missing required fields" → Response format issue

## Quick Fixes

### Fix 1: Update Base URL for Android Emulator
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

### Fix 2: Hot Restart After URL Change
```bash
# In terminal where flutter is running:
# Press 'R' for hot restart (not 'r' for hot reload)
R
```

### Fix 3: Verify Backend Response Format
Add this to your backend logs to see what it's sending:
```java
// In your backend login endpoint
logger.info("Login response: {}", response);
```

## Share Debug Output

When asking for help, share these logs:
1. The API endpoint being called
2. The error type and status code
3. The response data (if any)
4. Your device/emulator type

Example:
```
💡 AuthService: API endpoint: http://192.168.1.100:8080/auth/login
❌ AuthService: Login failed with DioException
   - Error type: DioExceptionType.connectionError
   - Status code: null
   - Response data: null
   - Device: Android Emulator (API 34)
```

## Next Steps

1. **Run the app** and attempt login
2. **Check the logs** for detailed error information
3. **Identify the specific error** from the logs
4. **Apply the appropriate fix** from this guide
5. **Hot restart** the app (press `R` in terminal)
6. **Try again**

The enhanced logging will tell you exactly what's going wrong!


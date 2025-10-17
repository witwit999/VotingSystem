# Test Backend Connection

## Quick Connection Test

### Step 1: Verify Backend is Running

Open a terminal and test if the backend is running on port 8080:

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' \
  -i
```

**Expected Response:**
```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "user": {
    "id": "...",
    "username": "admin",
    "displayName": "Admin User",
    "role": "ADMIN"
  }
}
```

### Step 2: Check Backend Process

Verify the backend server is actually running:

```bash
# Check if port 8080 is in use
lsof -i :8080

# OR
netstat -an | grep 8080
```

**Expected Output:**
```
java    12345 user   123u  IPv6 0x...  0t0  TCP *:8080 (LISTEN)
```

### Step 3: Hot Restart Your Flutter App

After updating the API configuration, **do a full hot restart**:

**In Terminal:**
```
Press: R (capital R, not lowercase r)
```

**In VS Code:**
- Click the restart button (⟳)
- Or: `Cmd+Shift+P` → "Flutter: Hot Restart"

**In Android Studio:**
- Click the restart button in the debug toolbar

## Current Configuration

Your app is now configured for **iOS Simulator**:
```dart
baseUrl = 'http://localhost:8080'
wsUrl = 'ws://localhost:8080/ws'
```

## Troubleshooting

### If Backend Test Fails

**Error: "Connection refused"**
```bash
curl: (7) Failed to connect to localhost port 8080: Connection refused
```

**Solutions:**
1. ✅ Start your backend server
2. ✅ Verify it's running on port 8080
3. ✅ Check for any errors in backend logs

**Error: "Empty reply from server"**
```bash
curl: (52) Empty reply from server
```

**Solutions:**
1. ✅ Backend is running but not responding
2. ✅ Check backend logs for errors
3. ✅ Verify the endpoint path is correct

### If Flutter App Still Can't Connect

**After hot restart, check logs:**
```
💡 AuthService: API endpoint: http://localhost:8080/auth/login
```

**If you see different URL:**
- Hot restart didn't work properly
- Try: **Stop the app completely** and **Run again**

**If you see connection error:**
```
❌ Error type: DioExceptionType.connectionError
```

1. Verify backend is running (Step 1 above)
2. Check firewall isn't blocking port 8080
3. Try pinging localhost:
   ```bash
   curl http://localhost:8080
   ```

## Backend Not Running?

### Start Your Backend

Depending on your backend setup:

**Spring Boot:**
```bash
cd /path/to/backend
./mvnw spring-boot:run
```

**OR**
```bash
java -jar target/your-app.jar
```

**Gradle:**
```bash
./gradlew bootRun
```

### Verify Backend Started Successfully

Look for this in backend logs:
```
Tomcat started on port(s): 8080 (http)
Started ParlvoteApplication in X.XXX seconds
```

## Network Configuration Reference

| Environment | Base URL | Why |
|-------------|----------|-----|
| **iOS Simulator** | `http://localhost:8080` | Can access host's localhost directly |
| **Android Emulator** | `http://10.0.2.2:8080` | Special alias for host's localhost |
| **Physical Device** | `http://192.168.1.100:8080` | Your PC's LAN IP address |

## Quick Test Script

Save this as `test-backend.sh`:

```bash
#!/bin/bash

echo "Testing backend connection..."
echo ""

# Test 1: Check if port is open
echo "1. Checking if port 8080 is listening..."
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "   ✅ Port 8080 is open"
else
    echo "   ❌ Port 8080 is not listening"
    echo "   → Start your backend server first!"
    exit 1
fi

# Test 2: Try to login
echo ""
echo "2. Testing login endpoint..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Login successful!"
    echo "   Response: $(echo "$BODY" | jq -r '.user.username // "OK"' 2>/dev/null || echo "OK")"
else
    echo "   ❌ Login failed with status: $HTTP_CODE"
    echo "   Response: $BODY"
fi

echo ""
echo "Backend test complete!"
```

Run it:
```bash
chmod +x test-backend.sh
./test-backend.sh
```

## Next Steps

1. ✅ Verify backend is running (curl test above)
2. ✅ Hot restart your Flutter app (Press `R`)
3. ✅ Try login again
4. ✅ Check the detailed logs

The app should now connect successfully! 🚀


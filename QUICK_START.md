# Quick Start Guide - Backend Integration

## ⚡ Quick Setup

### 1. Configure API Base URL
Open `lib/core/constants/api_constants.dart` and set the appropriate base URL:

```dart
// For Android Emulator (default)
static const String baseUrl = androidEmulatorBaseUrl; // http://10.0.2.2:8080

// For Physical Device - change to your PC's IP
static const String baseUrl = 'http://192.168.X.X:8080';

// For iOS Simulator
static const String baseUrl = 'http://localhost:8080';
```

### 2. Start Backend Server
Ensure your backend is running on the configured port (default: 8080)

### 3. Test Login

Use these seed credentials:

**Admin Account:**
- Username: `admin`
- Password: `admin123`

**Member Account:**
- Username: `member1`
- Password: `member123`

Additional members: `member2`, `member3`, `member4`, `member5` (all with password: `member123`)

## 📋 What's Been Implemented

### ✅ Authentication Endpoints
- **POST /auth/login** - Login with username/password
- **GET /auth/me** - Get current user profile
- **POST /auth/refresh** - Refresh access token

### ✅ Features
- Automatic JWT token management
- Auto token refresh on expiration
- Secure local storage
- Error handling with user-friendly messages
- Request retry on token refresh

## 🔧 Key Files Modified

1. **API Configuration**
   - `lib/core/constants/api_constants.dart` - New file

2. **Models**
   - `lib/models/user_model.dart` - Updated schema

3. **Services**
   - `lib/services/api_service.dart` - Enhanced with auto-refresh
   - `lib/services/auth_service.dart` - Real API integration
   - `lib/services/mock_data_service.dart` - Updated for new schema

4. **Providers**
   - `lib/providers/auth_provider.dart` - Updated dependencies

5. **UI**
   - `lib/features/auth/screens/login_screen.dart` - Updated credentials

## 🎯 Testing Checklist

- [ ] Backend server is running
- [ ] Base URL is correctly configured
- [ ] Can login with admin credentials
- [ ] Can login with member credentials
- [ ] Error shown for invalid credentials
- [ ] User can logout successfully
- [ ] App remembers login after restart

## 🔄 Next Steps

Now that authentication is integrated, you can proceed with:

1. **Session Management** - Join/leave sessions, list sessions
2. **WebSocket Integration** - Real-time updates
3. **Voting System** - Create decisions, vote, view results
4. **Chat System** - DM and group messaging
5. **Document Management** - Upload/download files

## 📞 Need Help?

See `AUTH_INTEGRATION_GUIDE.md` for detailed documentation.

## 🐛 Common Issues

**Can't connect to backend:**
- Check base URL configuration
- Verify backend is running
- Ensure device/emulator can reach the backend

**Login fails:**
- Verify credentials (case-sensitive)
- Check backend logs for errors
- Ensure MongoDB is running with seed data

**Token errors:**
- Clear app data and login again
- Check token expiration settings in backend


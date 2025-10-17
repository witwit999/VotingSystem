# Authentication Integration Guide

## Overview
This document describes the authentication integration with the Parlvote backend API. The authentication system has been updated to use real REST API endpoints instead of mock data.

## What Has Been Implemented

### 1. API Configuration (`lib/core/constants/api_constants.dart`)
- **Base URLs** configured for different environments:
  - Development: `http://localhost:8080`
  - Android Emulator: `http://10.0.2.2:8080` (default)
  - Physical Device: Configure with your PC's LAN IP
- **WebSocket URL**: `ws://10.0.2.2:8080/ws`
- **Endpoint paths**: `/auth/login`, `/auth/refresh`, `/auth/me`

### 2. User Model Updates (`lib/models/user_model.dart`)
Updated to match backend API schema:
- `username` (instead of `email`)
- `displayName` (instead of `name`)
- `role` (values: `ADMIN` or `USER`)
- Added backward compatibility getters: `name` and `email`

### 3. API Service (`lib/services/api_service.dart`)
Enhanced with:
- Automatic token management (Bearer authentication)
- Automatic token refresh on 401 errors
- Retry failed requests after token refresh
- Backend error envelope parsing
- Comprehensive error handling with user-friendly messages

### 4. Authentication Service (`lib/services/auth_service.dart`)
Implemented three main endpoints:

#### a. Login - `POST /auth/login`
```dart
Future<UserModel> login(String username, String password)
```
- Sends credentials to backend
- Receives and stores access token, refresh token, and user data
- Updates API service with new token
- Returns user model

#### b. Get Me - `GET /auth/me`
```dart
Future<UserModel> getMe()
```
- Fetches current user profile from backend
- Updates stored user data
- Requires valid access token

#### c. Refresh Token - `POST /auth/refresh`
```dart
Future<String> refreshAccessToken()
```
- Sends refresh token to get new access token
- Updates stored access token
- Called automatically by API service on 401 errors

### 5. Authentication Provider (`lib/providers/auth_provider.dart`)
- Integrated API service with auth service
- Added `refreshUser()` method to sync user data
- Added `currentUserProvider` helper
- Maintains authentication state using Riverpod

### 6. Login Screen Updates (`lib/features/auth/screens/login_screen.dart`)
- Updated demo credentials to match backend seed accounts:
  - **Admin**: `admin` / `admin123`
  - **Member**: `member1` / `member123`

## How It Works

### Authentication Flow

```
┌─────────────┐
│ User enters │
│ credentials │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ POST /auth/login│
└──────┬──────────┘
       │
       ▼
┌──────────────────────┐
│ Receive tokens & user│
│ - accessToken        │
│ - refreshToken       │
│ - user data          │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Store in local       │
│ SharedPreferences    │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Update app state     │
│ Navigate to home     │
└──────────────────────┘
```

### Token Refresh Flow

```
┌──────────────────┐
│ API call with    │
│ expired token    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Receive 401      │
│ Unauthorized     │
└────────┬─────────┘
         │
         ▼
┌──────────────────────┐
│ POST /auth/refresh   │
│ with refresh token   │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ Receive new          │
│ access token         │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ Retry original       │
│ request              │
└──────────────────────┘
```

## Configuration for Different Environments

### For Android Emulator (Default)
No changes needed - already configured in `api_constants.dart`:
```dart
static const String baseUrl = androidEmulatorBaseUrl; // http://10.0.2.2:8080
```

### For Physical Device
1. Find your PC's LAN IP address (e.g., `192.168.1.100`)
2. Update `api_constants.dart`:
```dart
static const String physicalDeviceBaseUrl = 'http://192.168.1.100:8080';
static const String baseUrl = physicalDeviceBaseUrl;
```

### For iOS Simulator
Use `localhost` or your PC's LAN IP:
```dart
static const String baseUrl = 'http://localhost:8080';
```

## Testing the Integration

### Prerequisites
1. Backend server running on `http://localhost:8080`
2. MongoDB running with seed data
3. Flutter app connected via emulator or device

### Test Steps

1. **Test Login with Admin**
   - Username: `admin`
   - Password: `admin123`
   - Expected: Login successful, role = `ADMIN`

2. **Test Login with Member**
   - Username: `member1`
   - Password: `member123`
   - Expected: Login successful, role = `USER`

3. **Test Invalid Credentials**
   - Username: `invalid`
   - Password: `wrong`
   - Expected: Error message displayed

4. **Test Token Refresh**
   - Wait for access token to expire (15 minutes)
   - Make any API call
   - Expected: Token automatically refreshed, request succeeds

5. **Test Logout**
   - Click logout
   - Expected: Tokens cleared, redirected to login

## Error Handling

The system handles various error scenarios:

| Error Code | Scenario | Handling |
|------------|----------|----------|
| 401 | Expired token | Automatic token refresh & retry |
| 401 | Invalid credentials | Show error message |
| 403 | Forbidden | Show "Access forbidden" |
| 404 | Not found | Show "Resource not found" |
| 500 | Server error | Show "Server error, try again" |
| Network | Connection issue | Show "Check your connection" |

## Security Features

1. **JWT Tokens**: RS256 signed tokens with expiration
2. **Secure Storage**: Tokens stored in SharedPreferences
3. **Automatic Refresh**: Expired tokens refreshed automatically
4. **Token Cleanup**: All tokens removed on logout
5. **Bearer Auth**: All authenticated requests use Bearer token

## Data Persistence

The following data is stored locally:
- **access_token**: JWT access token (15 min TTL)
- **refresh_token**: JWT refresh token (7 day TTL)
- **user_data**: User profile JSON

## Next Steps

Now that authentication is integrated, you can:

1. **Add WebSocket Integration** for real-time features
2. **Integrate Session Management** endpoints
3. **Implement Chat Features** with DM and groups
4. **Add Voting System** with decisions
5. **Implement Document Management** with file upload/download

## Troubleshooting

### Common Issues

**Issue**: Login fails with connection error
- **Solution**: Check backend is running, verify base URL configuration

**Issue**: Token refresh fails
- **Solution**: Ensure refresh token is valid and not expired (7 days)

**Issue**: 401 errors persist
- **Solution**: Clear app data and login again

**Issue**: Can't connect from physical device
- **Solution**: Use PC's LAN IP, ensure both on same network

### Debug Mode

To enable detailed logging, add to `api_service.dart`:
```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

## API Reference

### Login
```
POST /auth/login
Content-Type: application/json

{
  "username": "string",
  "password": "string"
}

Response 200:
{
  "accessToken": "string",
  "refreshToken": "string",
  "user": {
    "id": "string",
    "username": "string",
    "displayName": "string",
    "role": "ADMIN" | "USER"
  }
}
```

### Get Me
```
GET /auth/me
Authorization: Bearer <accessToken>

Response 200:
{
  "id": "string",
  "username": "string",
  "displayName": "string",
  "role": "ADMIN" | "USER"
}
```

### Refresh Token
```
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "string"
}

Response 200:
{
  "accessToken": "string"
}
```

## Summary

The authentication system is now fully integrated with the backend API:
- ✅ Login with username/password
- ✅ Automatic token management
- ✅ Token refresh on expiration
- ✅ Get current user profile
- ✅ Secure token storage
- ✅ Error handling
- ✅ Logout functionality

You can now proceed to integrate other features like sessions, voting, chat, and documents.


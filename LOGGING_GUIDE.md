# Logging Guide

## Overview

The application now uses the `logger` package for comprehensive debug logging throughout the codebase. This provides colorful, formatted, and structured logging in the debug console.

## Logger Features

### ✅ What's Been Added

1. **Centralized Logger** - `lib/core/utils/app_logger.dart`
2. **Comprehensive Logging** - Added to all authentication flows
3. **Colorful Output** - Different colors for different log levels
4. **Stack Traces** - Automatic stack trace capture for errors
5. **Performance Metrics** - Timing information for requests

## Log Levels

The logger supports multiple log levels:

| Level | Method | Use Case | Color |
|-------|--------|----------|-------|
| **Trace** | `AppLogger.trace()` | Very verbose debugging | Gray |
| **Debug** | `AppLogger.debug()` | Development debugging | Blue |
| **Info** | `AppLogger.info()` | General information | Green |
| **Warning** | `AppLogger.warning()` | Potential issues | Yellow |
| **Error** | `AppLogger.error()` | Errors and exceptions | Red |
| **Fatal** | `AppLogger.fatal()` | Critical failures | Red Background |

## Usage Examples

### Basic Logging

```dart
import '../core/utils/app_logger.dart';

// Info message
AppLogger.info('User logged in successfully');

// Debug message
AppLogger.debug('Token extracted from response');

// Warning
AppLogger.warning('API response took longer than expected');

// Error with exception
AppLogger.error('Failed to parse response', exception);

// Error with exception and stack trace
AppLogger.error('Login failed', exception, stackTrace);
```

### In Authentication Flow

The authentication system now logs all critical operations:

```dart
// Login attempt
AppLogger.info('Login attempt for user: admin');

// Login success
AppLogger.info('Login completed successfully for user: admin (ADMIN)');

// Login failure
AppLogger.error('Login failed with DioException', exception, stackTrace);

// Token refresh
AppLogger.info('Token refreshed successfully, retrying request');

// Logout
AppLogger.info('Logout completed, all tokens cleared');
```

## Current Logging Coverage

### ✅ LoginScreen (`login_screen.dart`)
- Empty credentials warning
- Login attempt logging
- Login success/failure
- Widget lifecycle (mounted checks)

### ✅ AuthService (`auth_service.dart`)
- Login flow (start, token extraction, save, complete)
- Logout flow
- All error scenarios with stack traces

### ✅ ApiService (`api_service.dart`)
- Every API request (with/without token)
- Request failures with status codes
- Token refresh attempts
- Token refresh success/failure

### ✅ AuthProvider (`auth_provider.dart`)
- Provider initialization
- Auth status checks
- Login state updates
- Logout state changes
- User data refresh

## Log Output Example

When you run the app, you'll see formatted logs like:

```
💡 INFO    AuthNotifier: Initializing, checking auth status
💡 INFO    AuthNotifier: No existing user session found
💡 INFO    Login attempt for user: admin
💡 INFO    AuthNotifier: Login requested for: admin
💡 INFO    AuthService: Attempting login for username: admin
🐛 DEBUG   ApiService: Request to /auth/login without token
🐛 DEBUG   AuthService: Login response received with status 200
🐛 DEBUG   AuthService: Tokens extracted, parsing user data
💡 INFO    AuthService: Tokens and user data saved successfully
💡 INFO    AuthService: Login completed successfully for user: admin (ADMIN)
💡 INFO    AuthNotifier: Login state updated successfully
```

Error example:

```
⚠️  WARNING Login attempted with empty credentials
❌ ERROR   AuthService: Login failed with DioException
          DioException [connection timeout]: The connection has timed out
          #0      AuthService.login (lib/services/auth_service.dart:67)
          #1      AuthNotifier.login (lib/providers/auth_provider.dart:49)
```

## Fixed Issues

### ✅ setState() After Dispose Error

**Problem:** `setState()` was being called after the widget was disposed, causing errors when login succeeded and navigated away.

**Solution:** Added `mounted` checks before all `setState()` calls:

```dart
// Before
setState(() => _isLoading = false);

// After
if (mounted) {
  setState(() => _isLoading = false);
}
```

**Implementation:**
```dart
Future<void> _handleLogin(BuildContext context) async {
  // ...
  if (!mounted) return;
  setState(() => _isLoading = true);
  
  try {
    await ref.read(authStateProvider.notifier).login(username, password);
  } finally {
    // Check if widget is still mounted before calling setState
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

## Configuration

The logger is configured in `app_logger.dart` with:

### Simple Printer (Default)
Clean, readable output without ANSI color codes:

```dart
Logger(
  printer: SimplePrinter(
    colors: false,           // Disabled for Flutter console
    printTime: true,         // Show timestamps
  ),
);
```

### Pretty Printer (Alternative)
For more detailed output with stack traces and formatting:

```dart
Logger(
  printer: PrettyPrinter(
    methodCount: 2,           // Stack trace depth
    errorMethodCount: 8,      // Error stack trace depth
    lineLength: 120,          // Console line length
    colors: false,            // Disabled for Flutter console compatibility
    printEmojis: true,        // Emoji prefixes
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
```

**Note:** ANSI colors are disabled because Flutter's debug console doesn't always render them properly, which can result in escape sequences like `\^[[38;5;12m` appearing in the output.

## Best Practices

### 1. **Use Appropriate Log Levels**
```dart
// ✅ Good
AppLogger.info('User action completed');
AppLogger.error('Operation failed', exception);

// ❌ Bad
AppLogger.error('User clicked button');  // Should be debug or info
```

### 2. **Include Context**
```dart
// ✅ Good
AppLogger.info('Login attempt for user: $username');

// ❌ Bad
AppLogger.info('Login attempt');
```

### 3. **Log Errors with Stack Traces**
```dart
// ✅ Good
try {
  // operation
} catch (e, stackTrace) {
  AppLogger.error('Operation failed', e, stackTrace);
}

// ❌ Bad
try {
  // operation
} catch (e) {
  AppLogger.error('Operation failed');
}
```

### 4. **Don't Log Sensitive Data**
```dart
// ❌ NEVER LOG PASSWORDS OR TOKENS IN FULL
AppLogger.info('Login with password: $password');  // BAD!
AppLogger.info('Token: $accessToken');              // BAD!

// ✅ Good - Log only usernames or partial data
AppLogger.info('Login attempt for user: $username');
AppLogger.debug('Token received: ${accessToken.substring(0, 10)}...');
```

## Troubleshooting

### View Logs in Different IDEs

**VS Code:**
- Debug Console tab automatically shows colored logs

**Android Studio:**
- Run tab shows formatted logs
- Use Logcat filter for additional filtering

**Terminal:**
```bash
flutter run --verbose
```

### Filter Logs

Search for specific components:
```
AuthService
ApiService
AuthNotifier
LoginScreen
```

## Performance

The logger is designed for **development only**. For production:

1. Logger only outputs in debug mode
2. Consider removing verbose logs in production builds
3. Use conditional logging if needed:

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  AppLogger.debug('Debug information');
}
```

## Adding Logging to New Features

When implementing new features, add logging for:

1. **Entry Points** - When function/method is called
2. **Success Cases** - When operation completes successfully
3. **Error Cases** - All exceptions with stack traces
4. **State Changes** - Important state transitions
5. **API Calls** - Request start and completion

Example template:
```dart
Future<void> newFeature() async {
  AppLogger.info('NewFeature: Starting operation');
  
  try {
    // Your code here
    AppLogger.debug('NewFeature: Intermediate step completed');
    
    // More code
    AppLogger.info('NewFeature: Operation completed successfully');
  } catch (e, stackTrace) {
    AppLogger.error('NewFeature: Operation failed', e, stackTrace);
    rethrow;
  }
}
```

## Summary

✅ **Logger package integrated** - `logger: ^2.0.2`  
✅ **Centralized logging utility** - `AppLogger` class  
✅ **Comprehensive auth logging** - All auth flows covered  
✅ **setState issue fixed** - Mounted checks added  
✅ **Production-ready** - Safe for production builds  

The logging system will help you debug issues, understand application flow, and monitor authentication operations in real-time during development.


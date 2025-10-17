# Conference Management System (Parlvote Mobile Client)

A comprehensive Flutter-based mobile application for government conference and parliamentary session management, integrated with the Parlvote backend API.

## 🎯 Project Overview

This mobile application provides a complete solution for managing parliamentary sessions, enabling real-time voting, document sharing, chat communication, and attendance tracking. Built with Flutter for cross-platform support (iOS, Android, Web, Windows, macOS, Linux).

## ✨ Features

### 🔐 **Authentication System**
- JWT-based authentication with automatic token refresh
- Role-based access control (Admin/Member)
- Secure token storage
- Session persistence
- Multi-language support (English/Arabic)

### 📋 **Session Management**
- View live, draft, paused, closed, and archived sessions
- Join/leave sessions with one tap
- Real-time session status updates
- Admin controls for session lifecycle (create, open, pause, close, archive)
- Comprehensive session filtering

### 👥 **Member Features**
- **Home Dashboard** - View live sessions and active decisions
- **Session Joining** - Join live sessions to participate
- **Agenda Viewing** - Access session agendas and materials
- **Voting** - Participate in decisions (coming soon)
- **Documents** - Access and upload session documents (coming soon)
- **Chat** - DM and group messaging (coming soon)
- **Speaker Queue** - Request to speak (coming soon)
- **Profile** - Manage user profile and settings

### 🛡️ **Admin Features**
- **Dashboard** - Overview of all sessions and activities
- **Session Management** - Create, open, pause, close, archive sessions
- **Member Management** - View and manage members
- **Voting Control** - Create and manage decisions
- **Attendance Tracking** - Monitor member attendance
- **Document Management** - Upload and share documents
- **Reports** - Generate session reports and analytics
- **Speaking Queue** - Manage speaker requests and mute controls

## 🏗️ **Tech Stack**

### Frontend:
- **Flutter 3.7.2** - Cross-platform mobile framework
- **Dart** - Programming language
- **Riverpod 2.5.1** - State management
- **Go Router 14.2.0** - Navigation
- **Dio 5.4.3** - HTTP client with interceptors
- **Logger 2.0.2** - Debugging and logging
- **Animate Do 3.3.4** - UI animations

### Backend Integration:
- **Parlvote REST API** - RESTful API integration
- **JWT Authentication** - RS256 signed tokens
- **WebSocket/STOMP** - Real-time communication (planned)
- **MongoDB** - Database (backend)

## 📱 **Platforms Supported**

- ✅ iOS (iPhone & iPad)
- ✅ Android (Phone & Tablet)
- ✅ Web (Progressive Web App)
- ✅ Windows Desktop
- ✅ macOS Desktop
- ✅ Linux Desktop

## 🚀 **Getting Started**

### Prerequisites:
```bash
# Flutter SDK 3.7.2 or higher
flutter --version

# Backend server running
# Default: http://localhost:8080
```

### Installation:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/witwit999/VotingSystem.git
   cd VotingSystem
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   
   Edit `lib/core/constants/api_constants.dart`:
   
   ```dart
   // For iOS Simulator
   static const String baseUrl = 'http://localhost:8080';
   
   // For Android Emulator
   static const String baseUrl = 'http://10.0.2.2:8080';
   
   // For Physical Device
   static const String baseUrl = 'http://YOUR_PC_IP:8080';
   ```

4. **Run the app:**
   ```bash
   # iOS Simulator
   flutter run -d iPhone
   
   # Android Emulator
   flutter run -d emulator-5554
   
   # Chrome (Web)
   flutter run -d chrome
   ```

### Test Credentials:

**Admin Account:**
- Username: `admin`
- Password: `admin123`

**Member Accounts:**
- Username: `member1` (or member2-5)
- Password: `member123`

## 📚 **Documentation**

### Quick Start:
- **[QUICK_START.md](QUICK_START.md)** - Quick setup guide
- **[TEST_CONNECTION.md](TEST_CONNECTION.md)** - Test backend connectivity

### Integration Guides:
- **[AUTH_INTEGRATION_GUIDE.md](AUTH_INTEGRATION_GUIDE.md)** - Authentication integration
- **[SESSION_INTEGRATION_GUIDE.md](SESSION_INTEGRATION_GUIDE.md)** - Session management
- **[Backend_reference.md](Backend_reference.md)** - Complete API documentation

### Troubleshooting:
- **[LOGIN_TROUBLESHOOTING.md](LOGIN_TROUBLESHOOTING.md)** - Login issues
- **[LOGGING_GUIDE.md](LOGGING_GUIDE.md)** - Debug logging system

### Reference:
- **[INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)** - What's integrated
- **[FIXES_APPLIED.md](FIXES_APPLIED.md)** - Changelog
- **[SESSIONS_INTEGRATION_COMPLETE.md](SESSIONS_INTEGRATION_COMPLETE.md)** - Session integration summary

## 🛠️ **Project Structure**

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # API endpoints and configuration
│   │   └── app_colors.dart         # Color theme
│   ├── localization/
│   │   └── app_localizations.dart  # i18n support (English/Arabic)
│   ├── router/
│   │   └── app_router.dart         # Navigation and routing
│   ├── theme/
│   │   └── app_theme.dart          # App theme configuration
│   ├── utils/
│   │   └── app_logger.dart         # Centralized logging
│   └── widgets/
│       └── [9 reusable widgets]    # Custom UI components
├── features/
│   ├── auth/
│   │   └── screens/
│   │       └── login_screen.dart   # Authentication UI
│   ├── admin/
│   │   └── [7 admin features]      # Admin-only screens
│   └── member/
│       └── [7 member features]     # Member screens
├── models/
│   ├── user_model.dart             # User data model
│   ├── session_model.dart          # Session data model
│   └── [6 other models]            # Other data models
├── providers/
│   ├── auth_provider.dart          # Auth state management
│   ├── session_provider.dart      # Session state management
│   └── [7 other providers]         # Other providers
├── services/
│   ├── api_service.dart            # HTTP client with interceptors
│   ├── auth_service.dart           # Authentication API calls
│   ├── session_service.dart        # Session API calls
│   └── mock_data_service.dart      # Mock data for testing
└── main.dart                       # App entry point
```

## 🔑 **Key Features & Implementation Status**

| Feature | Status | Description |
|---------|--------|-------------|
| **Authentication** | ✅ Complete | Login, logout, token refresh |
| **Session Listing** | ✅ Complete | View sessions with status filtering |
| **Session Join/Leave** | ✅ Complete | Members join/leave sessions |
| **Session Lifecycle** | ✅ Complete | Admin create, open, pause, close, archive |
| **WebSocket** | 🚧 Planned | Real-time updates via STOMP |
| **Voting/Decisions** | 🚧 Planned | Cast votes, view results |
| **Chat** | 🚧 Planned | DM and group messaging |
| **Documents** | 🚧 Planned | Upload/download files |
| **Agenda** | 🚧 Planned | View and manage agendas |
| **Speaking Queue** | 🚧 Planned | Hand-raise and mute controls |

## 🔒 **Security Features**

- **JWT Authentication** - RS256 signed tokens
- **Automatic Token Refresh** - Expired tokens refreshed automatically
- **Secure Storage** - Tokens stored in SharedPreferences
- **Role-Based Access** - Admin/Member route protection
- **API Interceptors** - Automatic Bearer token injection
- **Error Handling** - Comprehensive error management

## 🌐 **API Integration**

### Base Configuration:
```dart
// Development
http://localhost:8080 (backend)
ws://localhost:8080/ws (WebSocket)

// Swagger UI
http://localhost:8080/swagger-ui

// OpenAPI Spec
http://localhost:8080/v3/api-docs
```

### Integrated Endpoints:

#### Authentication:
- ✅ `POST /auth/login` - Login with credentials
- ✅ `GET /auth/me` - Get current user
- ✅ `POST /auth/refresh` - Refresh access token

#### Sessions:
- ✅ `GET /sessions` - List sessions with filtering
- ✅ `GET /sessions/{id}` - Get session details
- ✅ `POST /sessions/{id}/join` - Join session
- ✅ `POST /sessions/{id}/leave` - Leave session
- ✅ `POST /sessions` - Create session (admin)
- ✅ `POST /sessions/{id}/open` - Open session (admin)
- ✅ `POST /sessions/{id}/pause` - Pause session (admin)
- ✅ `POST /sessions/{id}/close` - Close session (admin)
- ✅ `POST /sessions/{id}/archive` - Archive session (admin)

#### Coming Soon:
- 🚧 Decisions & Voting
- 🚧 Documents
- 🚧 Chat & Messaging
- 🚧 Attendance
- 🚧 Speaking Queue & Mute

## 🧪 **Running Tests**

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Test with coverage
flutter test --coverage
```

## 🏗️ **Building**

### Android:
```bash
flutter build apk                # Debug APK
flutter build apk --release      # Release APK
flutter build appbundle          # Android App Bundle
```

### iOS:
```bash
flutter build ios                # Debug IPA
flutter build ios --release      # Release IPA
```

### Web:
```bash
flutter build web --release
```

## 📝 **Development Guidelines**

### Adding New Features:
1. Create model in `lib/models/`
2. Create service in `lib/services/`
3. Create provider in `lib/providers/`
4. Create UI in `lib/features/`
5. Add localization strings
6. Add comprehensive logging
7. Test thoroughly

### Logging:
```dart
import '../core/utils/app_logger.dart';

AppLogger.info('Operation started');
AppLogger.debug('Detailed debug info');
AppLogger.error('Error occurred', exception, stackTrace);
```

### State Management:
```dart
// Read once
ref.read(sessionProvider);

// Watch for changes
ref.watch(sessionProvider);

// Call methods
await ref.read(sessionProvider.notifier).joinSession(id);
```

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 **License**

This project is private and confidential.

## 👨‍💻 **Authors**

- Development Team
- Backend: Parlvote API
- Frontend: Flutter Application

## 🙏 **Acknowledgments**

- Flutter team for the amazing framework
- Riverpod for state management
- Dio for HTTP client
- Backend team for the Parlvote API

## 📞 **Support**

For issues and questions:
1. Check documentation in the repository
2. Review troubleshooting guides
3. Check logs for detailed error information
4. Contact the development team

## 🗺️ **Roadmap**

### Phase 1: Foundation (✅ Complete)
- ✅ Authentication system
- ✅ Session management
- ✅ UI framework
- ✅ State management
- ✅ Logging system

### Phase 2: Real-time Features (🚧 In Progress)
- 🚧 WebSocket integration
- 🚧 Heartbeat mechanism
- 🚧 Real-time session updates
- 🚧 Live voting

### Phase 3: Core Features (📋 Planned)
- 📋 Voting and decisions
- 📋 Document management
- 📋 Chat and messaging
- 📋 Agenda management

### Phase 4: Advanced Features (📋 Planned)
- 📋 Speaking queue
- 📋 Mute controls
- 📋 Attendance tracking
- 📋 Reports and analytics

### Phase 5: Polish (📋 Planned)
- 📋 Performance optimization
- 📋 Offline support
- 📋 Push notifications
- 📋 Advanced analytics

## 📊 **Project Statistics**

- **Total Lines:** 20,560+
- **Files:** 204+
- **Languages:** Dart, Kotlin, Swift, C++
- **Screens:** 14+ feature screens
- **Models:** 8 data models
- **Services:** 3+ API services
- **Providers:** 9+ state providers
- **Widgets:** 9+ custom components

## 🔗 **Repository**

**GitHub:** https://github.com/witwit999/VotingSystem

---

**Built with ❤️ using Flutter**

**Version:** 1.0.0  
**Last Updated:** October 17, 2025

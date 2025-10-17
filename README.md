# Conference & Meeting Management System

A modern, professional Conference & Meeting Management System with role-based access for government meetings, boardrooms, or parliaments. Built with Flutter using clean architecture, Riverpod state management, and GoRouter.

## Features

### 🎯 Two Role-Based Interfaces

#### Member Interface (Tablet App)
- **Login**: RFID/Fingerprint scanning (mocked) and credential-based authentication
- **Home Dashboard**: Personalized greeting, quick stats, and navigation cards
- **Agenda**: View meeting agenda, mark attendance, filter by status
- **Voting**: Participate in voting sessions with real-time results
- **Documents**: Access meeting materials with document viewer
- **Chat**: Group messaging with all members
- **Speaker Request**: Request to speak with queue management
- **Profile**: View attendance summary and personal information

#### Admin Interface (Control Room)
- **Dashboard**: Overview with stats for members, sessions, votes, and attendance
- **Sessions Management**: Create, edit, and manage meeting sessions
- **Members Management**: View all members, grant/revoke microphone access
- **Voting Control**: Start/stop voting sessions with live results visualization
- **Documents Management**: Upload and manage meeting documents
- **Attendance**: Real-time attendance tracking with export capability
- **Reports**: Comprehensive voting and attendance reports with charts

## Technology Stack

- **Framework**: Flutter 3.7.2+
- **State Management**: Riverpod 2.5.1
- **Routing**: GoRouter 14.2.0
- **HTTP Client**: Dio 5.4.3
- **Charts**: FL Chart 0.68.0
- **Animations**: Animate Do 3.3.4
- **Local Storage**: Shared Preferences 2.2.3
- **File Handling**: File Picker 8.0.3

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants and colors
│   ├── router/             # GoRouter configuration with role-based access
│   ├── theme/              # App theme and styling
│   └── widgets/            # Reusable widgets
├── features/
│   ├── auth/               # Authentication screens
│   ├── member/             # Member interface features
│   │   ├── home/
│   │   ├── agenda/
│   │   ├── voting/
│   │   ├── documents/
│   │   ├── chat/
│   │   ├── speaker/
│   │   └── profile/
│   └── admin/              # Admin interface features
│       ├── dashboard/
│       ├── sessions/
│       ├── members/
│       ├── voting_control/
│       ├── documents/
│       ├── attendance/
│       └── reports/
├── models/                 # Data models
├── providers/              # Riverpod state providers
└── services/               # API and data services
```

## Getting Started

### Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.0.0 or higher
- iOS/Android/Web development environment

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd conference_management
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

### Login Credentials (Mock Data)

**Member Account:**
- Email: `member@conference.gov`
- Password: Any password (mock authentication)
- Role: Select "Member"

**Admin Account:**
- Email: `admin@conference.gov`
- Password: Any password (mock authentication)
- Role: Select "Admin"

### RFID/Fingerprint Login

The RFID/Fingerprint button simulates device scanning with a 2-second delay. Select your role (Member/Admin) before clicking.

## Design Theme

- **Primary Color**: Green (#00C853)
- **Background**: White (#FFFFFF)
- **Text**: Black (#000000)
- **Accent Colors**: 
  - Success: Green
  - Error: Red
  - Warning: Orange
  - Info: Blue

## Backend Integration

This is a **prototype with mock data**. To integrate with a real backend:

1. Update API endpoints in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'YOUR_BACKEND_URL';
```

2. Implement actual API calls in service files:
   - `lib/services/auth_service.dart`
   - Service files in `lib/services/` directory

3. Update models in `lib/models/` to match your API response structure

4. The app uses Dio with interceptors for:
   - Token management
   - Error handling
   - Request/response logging

## State Management

The app uses **Riverpod** for state management with the following providers:

- `authStateProvider`: Authentication state
- `agendaProvider`: Agenda items
- `votingProvider`: Voting sessions
- `documentProvider`: Documents
- `chatProvider`: Messages
- `memberProvider`: Members list
- `sessionProvider`: Sessions
- `attendanceProvider`: Attendance data

## Routing

Role-based routing with GoRouter ensures:
- Automatic redirection based on authentication status
- Member routes: `/member/*`
- Admin routes: `/admin/*`
- Route guards prevent unauthorized access

## Mock Data

The app includes comprehensive mock data in `lib/services/mock_data_service.dart`:
- Sample users (member and admin)
- Meeting agenda items
- Voting sessions with results
- Documents
- Chat messages
- Members list
- Attendance records

## Animations

Smooth animations throughout the app using:
- Page transitions
- FadeIn/FadeOut effects
- Slide animations
- Pulse effects for active states

## Responsive Design

Optimized for tablet devices with:
- Adaptive layouts
- Touch-friendly UI elements
- Large, easy-to-tap buttons
- Clear visual hierarchy

## Future Enhancements

- [ ] Real backend integration
- [ ] Push notifications
- [ ] Offline mode
- [ ] Document annotation
- [ ] Video conferencing integration
- [ ] Multi-language support
- [ ] Dark theme
- [ ] Export reports to PDF
- [ ] Real-time updates via WebSocket

## Contributing

This is a prototype project. For production use, implement:
- Proper authentication and security
- Real backend API integration
- Error handling and recovery
- Unit and integration tests
- Performance optimization

## License

This project is a prototype for demonstration purposes.

## Support

For questions or issues, please contact the development team.

---

**Built with Flutter** 💙

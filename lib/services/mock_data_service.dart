import '../models/user_model.dart';
import '../models/agenda_model.dart';
import '../models/session_model.dart';
import '../models/voting_model.dart';
import '../models/document_model.dart';
import '../models/message_model.dart';
import '../models/member_model.dart';
import '../models/attendance_model.dart';

class MockDataService {
  // Mock Users
  static final UserModel memberUser = UserModel(
    id: '1',
    username: 'member1',
    displayName: 'Member 1',
    role: 'USER',
    title: 'Parliament Member',
    seatNumber: 'A-12',
    photo: null,
  );

  static final UserModel adminUser = UserModel(
    id: '2',
    username: 'admin',
    displayName: 'Admin User',
    role: 'ADMIN',
    title: 'System Administrator',
    photo: null,
  );

  // Mock Agenda Items
  static List<AgendaModel> getAgendaItems() {
    final now = DateTime.now();
    return [
      AgendaModel(
        id: '1',
        title: 'Opening Session',
        description: 'Welcome and introduction to the conference',
        speaker: 'Dr. Michael Brown',
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 1)),
        status: 'ongoing',
        hasAttended: true,
      ),
      AgendaModel(
        id: '2',
        title: 'Budget Proposal Discussion',
        description: 'Detailed discussion on the annual budget proposal',
        speaker: 'Finance Minister',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
        status: 'upcoming',
        hasAttended: false,
      ),
      AgendaModel(
        id: '3',
        title: 'Healthcare Reform Debate',
        description: 'Open debate on proposed healthcare reforms',
        speaker: 'Health Minister',
        startTime: now.add(const Duration(hours: 4)),
        endTime: now.add(const Duration(hours: 5)),
        status: 'upcoming',
        hasAttended: false,
      ),
      AgendaModel(
        id: '4',
        title: 'Infrastructure Development',
        description: 'Presentation on infrastructure projects',
        speaker: 'Minister of Public Works',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1, hours: -2)),
        status: 'completed',
        hasAttended: true,
      ),
    ];
  }

  // Mock Sessions
  static List<SessionModel> getSessions() {
    final now = DateTime.now();
    return [
      SessionModel(
        id: '1',
        title: 'Morning Session',
        speaker: 'Dr. Michael Brown',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 2)),
        description: 'Opening and main discussions',
        isActive: true,
      ),
      SessionModel(
        id: '2',
        title: 'Afternoon Session',
        speaker: 'Finance Minister',
        startTime: now.add(const Duration(hours: 3)),
        endTime: now.add(const Duration(hours: 6)),
        description: 'Budget and financial matters',
        isActive: false,
      ),
      SessionModel(
        id: '3',
        title: 'Evening Session',
        speaker: 'Health Minister',
        startTime: now.add(const Duration(hours: 7)),
        endTime: now.add(const Duration(hours: 9)),
        description: 'Healthcare and social policies',
        isActive: false,
      ),
    ];
  }

  // Mock Voting
  static VotingModel getCurrentVoting() {
    return VotingModel(
      id: '1',
      title: 'Budget Approval 2024',
      question: 'Do you approve the proposed budget for fiscal year 2024?',
      startTime: DateTime.now().subtract(const Duration(minutes: 10)),
      endTime: DateTime.now().add(
        const Duration(minutes: 15),
      ), // Timer: 15 minutes from now
      isActive: true,
      results: VotingResults(yes: 45, no: 12, abstain: 8, total: 65),
      userVote: null,
    );
  }

  static List<VotingModel> getVotingHistory() {
    final now = DateTime.now();
    return [
      VotingModel(
        id: '2',
        title: 'Healthcare Reform Bill',
        question: 'Do you support the healthcare reform bill?',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1, hours: -1)),
        isActive: false,
        results: VotingResults(yes: 52, no: 18, abstain: 5, total: 75),
        userVote: 'yes',
      ),
      VotingModel(
        id: '3',
        title: 'Infrastructure Investment',
        question: 'Approve infrastructure investment package?',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.subtract(const Duration(days: 2, hours: -2)),
        isActive: false,
        results: VotingResults(yes: 60, no: 10, abstain: 8, total: 78),
        userVote: 'yes',
      ),
    ];
  }

  // Mock Documents
  static List<DocumentModel> getDocuments() {
    final now = DateTime.now();
    return [
      DocumentModel(
        id: '1',
        title: 'Budget Proposal 2024.pdf',
        type: 'pdf',
        url: 'https://example.com/documents/budget-2024.pdf',
        uploadedAt: now.subtract(const Duration(hours: 5)),
        uploadedBy: 'Finance Department',
        size: 2457600, // 2.4 MB
        visibility: 'all',
      ),
      DocumentModel(
        id: '2',
        title: 'Healthcare Reform Overview.pdf',
        type: 'pdf',
        url: 'https://example.com/documents/healthcare-reform.pdf',
        uploadedAt: now.subtract(const Duration(hours: 12)),
        uploadedBy: 'Health Ministry',
        size: 1843200, // 1.8 MB
        visibility: 'all',
      ),
      DocumentModel(
        id: '3',
        title: 'Meeting Minutes - Previous Session.pdf',
        type: 'pdf',
        url: 'https://example.com/documents/minutes.pdf',
        uploadedAt: now.subtract(const Duration(days: 1)),
        uploadedBy: 'Secretary Office',
        size: 512000, // 500 KB
        visibility: 'admin_only',
      ),
      DocumentModel(
        id: '4',
        title: 'Infrastructure Map.png',
        type: 'image',
        url: 'https://example.com/documents/infra-map.png',
        uploadedAt: now.subtract(const Duration(days: 2)),
        uploadedBy: 'Public Works',
        size: 3145728, // 3 MB
        visibility: 'all',
      ),
    ];
  }

  // Mock Messages
  static List<MessageModel> getMessages() {
    final now = DateTime.now();
    return [
      MessageModel(
        id: '1',
        senderId: '3',
        senderName: 'Robert Davis',
        text: 'Good morning everyone! Looking forward to today\'s session.',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      MessageModel(
        id: '2',
        senderId: '4',
        senderName: 'Emily Wilson',
        text: 'Has anyone reviewed the budget proposal document?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
      ),
      MessageModel(
        id: '3',
        senderId: '1',
        senderName: 'John Smith',
        text: 'Yes, I have. It looks comprehensive.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      MessageModel(
        id: '4',
        senderId: '5',
        senderName: 'David Martinez',
        text: 'When does the voting session start?',
        timestamp: now.subtract(const Duration(minutes: 45)),
      ),
      MessageModel(
        id: '5',
        senderId: '2',
        senderName: 'Sarah Johnson',
        text: 'Voting will begin in approximately 15 minutes.',
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  // Mock Members
  static List<MemberModel> getMembers() {
    return [
      MemberModel(
        id: '1',
        name: 'John Smith',
        seatNumber: 'A-12',
        status: 'present',
        title: 'Parliament Member',
        hasMic: false,
      ),
      MemberModel(
        id: '3',
        name: 'Robert Davis',
        seatNumber: 'A-15',
        status: 'present',
        title: 'Parliament Member',
        hasMic: true,
      ),
      MemberModel(
        id: '4',
        name: 'Emily Wilson',
        seatNumber: 'B-08',
        status: 'present',
        title: 'Parliament Member',
        hasMic: false,
      ),
      MemberModel(
        id: '5',
        name: 'David Martinez',
        seatNumber: 'B-14',
        status: 'present',
        title: 'Parliament Member',
        hasMic: false,
      ),
      MemberModel(
        id: '6',
        name: 'Lisa Anderson',
        seatNumber: 'C-05',
        status: 'absent',
        title: 'Parliament Member',
        hasMic: false,
      ),
      MemberModel(
        id: '7',
        name: 'James Taylor',
        seatNumber: 'C-10',
        status: 'present',
        title: 'Parliament Member',
        hasMic: false,
      ),
    ];
  }

  // Mock Attendance
  static List<AttendanceModel> getAttendance() {
    final now = DateTime.now();
    return [
      AttendanceModel(
        id: '1',
        memberId: '1',
        memberName: 'John Smith',
        sessionId: '1',
        status: 'present',
        checkInTime: now.subtract(const Duration(hours: 2)),
        seatNumber: 'A-12',
      ),
      AttendanceModel(
        id: '2',
        memberId: '3',
        memberName: 'Robert Davis',
        sessionId: '1',
        status: 'present',
        checkInTime: now.subtract(const Duration(hours: 2, minutes: 5)),
        seatNumber: 'A-15',
      ),
      AttendanceModel(
        id: '3',
        memberId: '4',
        memberName: 'Emily Wilson',
        sessionId: '1',
        status: 'present',
        checkInTime: now.subtract(const Duration(hours: 1, minutes: 55)),
        seatNumber: 'B-08',
      ),
      AttendanceModel(
        id: '4',
        memberId: '5',
        memberName: 'David Martinez',
        sessionId: '1',
        status: 'present',
        checkInTime: now.subtract(const Duration(hours: 2, minutes: 10)),
        seatNumber: 'B-14',
      ),
      AttendanceModel(
        id: '5',
        memberId: '6',
        memberName: 'Lisa Anderson',
        sessionId: '1',
        status: 'absent',
        checkInTime: null,
        seatNumber: 'C-05',
      ),
      AttendanceModel(
        id: '6',
        memberId: '7',
        memberName: 'James Taylor',
        sessionId: '1',
        status: 'present',
        checkInTime: now.subtract(const Duration(hours: 2, minutes: 3)),
        seatNumber: 'C-10',
      ),
    ];
  }
}

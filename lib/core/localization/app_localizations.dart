import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _enStrings,
    'ar': _arStrings,
  };

  String get languageCode => locale.languageCode;
  bool get isArabic => locale.languageCode == 'ar';

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Common
  String get appName => translate('app_name');
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get filter => translate('filter');
  String get refresh => translate('refresh');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get close => translate('close');
  String get yes => translate('yes');
  String get no => translate('no');
  String get abstain => translate('abstain');

  // Language
  String get language => translate('language');
  String get english => translate('english');
  String get arabic => translate('arabic');
  String get selectLanguage => translate('select_language');

  // Auth
  String get login => translate('login');
  String get logout => translate('logout');
  String get username => translate('username');
  String get password => translate('password');
  String get enterUsername => translate('enter_username');
  String get enterPassword => translate('enter_password');
  String get welcomeTo => translate('welcome_to');
  String get smartConferenceSystem => translate('smart_conference_system');
  String get secureGovernmentConferenceManagement =>
      translate('secure_government_conference_management');
  String get demoCredentials => translate('demo_credentials');
  String get member => translate('member');
  String get admin => translate('admin');
  String get invalidCredentials => translate('invalid_credentials');
  String get enterUsernameAndPassword =>
      translate('enter_username_and_password');

  // Navigation
  String get home => translate('home');
  String get agenda => translate('agenda');
  String get voting => translate('voting');
  String get documents => translate('documents');
  String get chat => translate('chat');
  String get speaker => translate('speaker');
  String get profile => translate('profile');
  String get dashboard => translate('dashboard');
  String get sessions => translate('sessions');
  String get members => translate('members');
  String get votingControl => translate('voting_control');
  String get attendance => translate('attendance');
  String get reports => translate('reports');
  String get settings => translate('settings');

  // Home
  String get welcome => translate('welcome');
  String get currentSession => translate('current_session');
  String get activeVoting => translate('active_voting');
  String get upcomingAgenda => translate('upcoming_agenda');
  String get quickActions => translate('quick_actions');
  String get viewFullAgenda => translate('view_full_agenda');
  String get viewDocuments => translate('view_documents');
  String get joinChat => translate('join_chat');

  // Agenda
  String get agendaItems => translate('agenda_items');
  String get ongoing => translate('ongoing');
  String get upcoming => translate('upcoming');
  String get completed => translate('completed');
  String get allAgenda => translate('all_agenda');
  String get speaker_label => translate('speaker_label');
  String get startTime => translate('start_time');
  String get endTime => translate('end_time');
  String get status => translate('status');

  // Voting
  String get currentVoting => translate('current_voting');
  String get votingHistory => translate('voting_history');
  String get castYourVote => translate('cast_your_vote');
  String get voteYes => translate('vote_yes');
  String get voteNo => translate('vote_no');
  String get voteAbstain => translate('vote_abstain');
  String get votingResults => translate('voting_results');
  String get totalVotes => translate('total_votes');
  String get votingEnded => translate('voting_ended');
  String get votingActive => translate('voting_active');
  String get yourVote => translate('your_vote');
  String get notVotedYet => translate('not_voted_yet');

  // Documents
  String get recentDocuments => translate('recent_documents');
  String get uploadDocument => translate('upload_document');
  String get downloadDocument => translate('download_document');
  String get uploadedBy => translate('uploaded_by');
  String get uploadedAt => translate('uploaded_at');
  String get fileSize => translate('file_size');
  String get chooseFile => translate('choose_file');
  String get selectFile => translate('select_file');
  String get documentVisibility => translate('document_visibility');
  String get visibleToAll => translate('visible_to_all');
  String get visibleToAdminOnly => translate('visible_to_admin_only');
  String get allMembers => translate('all_members');
  String get adminOnly => translate('admin_only');
  String get uploading => translate('uploading');
  String get uploadSuccess => translate('upload_success');
  String get uploadFailed => translate('upload_failed');
  String get noFileSelected => translate('no_file_selected');
  String get pleaseSelectFile => translate('please_select_file');
  String get upload => translate('upload');

  // Chat
  String get conferenceChat => translate('conference_chat');
  String get typeMessage => translate('type_message');
  String get sendMessage => translate('send_message');
  String get noMessages => translate('no_messages');

  // Speaker
  String get requestMicrophone => translate('request_microphone');
  String get microphoneActive => translate('microphone_active');
  String get microphoneRequested => translate('microphone_requested');
  String get releaseMicrophone => translate('release_microphone');
  String get activeSpeakers => translate('active_speakers');
  String get speakerQueue => translate('speaker_queue');

  // Profile
  String get personalInfo => translate('personal_info');
  String get name => translate('name');
  String get email => translate('email');
  String get role => translate('role');
  String get title => translate('title');
  String get seatNumber => translate('seat_number');
  String get preferences => translate('preferences');
  String get changePassword => translate('change_password');

  // Admin Dashboard
  String get adminDashboard => translate('admin_dashboard');
  String get totalMembers => translate('total_members');
  String get presentMembers => translate('present_members');
  String get absentMembers => translate('absent_members');
  String get activeSession => translate('active_session');
  String get startSession => translate('start_session');
  String get endSession => translate('end_session');
  String get systemOverview => translate('system_overview');

  // Sessions Management
  String get sessionManagement => translate('session_management');
  String get createSession => translate('create_session');
  String get editSession => translate('edit_session');
  String get deleteSession => translate('delete_session');
  String get sessionTitle => translate('session_title');
  String get sessionDescription => translate('session_description');
  String get sessionSpeaker => translate('session_speaker');

  // Members Management
  String get membersManagement => translate('members_management');
  String get addMember => translate('add_member');
  String get editMember => translate('edit_member');
  String get deleteMember => translate('delete_member');
  String get memberDetails => translate('member_details');
  String get present => translate('present');
  String get absent => translate('absent');

  // Voting Control
  String get createVoting => translate('create_voting');
  String get endVoting => translate('end_voting');
  String get votingQuestion => translate('voting_question');
  String get votingTitle => translate('voting_title');
  String get startVoting => translate('start_voting');

  // Attendance
  String get attendanceTracking => translate('attendance_tracking');
  String get checkInTime => translate('check_in_time');
  String get attendanceRate => translate('attendance_rate');

  // Reports
  String get generateReport => translate('generate_report');
  String get exportReport => translate('export_report');
  String get sessionReports => translate('session_reports');
  String get votingReports => translate('voting_reports');
  String get attendanceReports => translate('attendance_reports');

  // Greetings
  String get goodMorning => translate('good_morning');
  String get goodAfternoon => translate('good_afternoon');
  String get goodEvening => translate('good_evening');

  // Member Home Screen
  String get quickAccess => translate('quick_access');
  String get todaysAgenda => translate('todays_agenda');
  String get ongoingLabel => translate('ongoing_label');
  String get next => translate('next');
  String get votingStatus => translate('voting_status');
  String get noActiveVoting => translate('no_active_voting');
  String get voteSubmitted => translate('vote_submitted');
  String get voteNow => translate('vote_now');
  String get meetingMaterials => translate('meeting_materials');
  String get noActiveSession => translate('no_active_session');
  String get noSessionsCurrently => translate('no_sessions_currently');
  String get timeRemaining => translate('time_remaining');
  String get enrollInSession => translate('enroll_in_session');
  String get joinVoting => translate('join_voting');
  String get votingEndsIn => translate('voting_ends_in');
  String get activeDecision => translate('active_decision');
  String get noActiveDecision => translate('no_active_decision');

  // Agenda Screen
  String get all => translate('all');
  String get noAgendaItems => translate('no_agenda_items');
  String get attended => translate('attended');
  String get loadingAgenda => translate('loading_agenda');
  String get markAttendance => translate('mark_attendance');
  String get attendanceMarked => translate('attendance_marked');
  String get description => translate('description');
  String get time => translate('time');
  String get date => translate('date');

  // Documents Screen
  String get noDocumentsAvailable => translate('no_documents_available');
  String get loadingDocuments => translate('loading_documents');
  String get documentViewer => translate('document_viewer');
  String get mockViewerForPrototype => translate('mock_viewer_for_prototype');
  String get zoom => translate('zoom');
  String get highlight => translate('highlight');
  String get note => translate('note');
  String get download => translate('download');
  String get share => translate('share');
  String get downloadFeatureComingSoon =>
      translate('download_feature_coming_soon');
  String get shareFeatureComingSoon => translate('share_feature_coming_soon');
  String get mb => translate('mb');

  // Chat Screen
  String get groupChat => translate('group_chat');
  String get noMessagesYet => translate('no_messages_yet');
  String get loadingMessages => translate('loading_messages');
  String get typeAMessage => translate('type_a_message');

  // Speaker Screen
  String get speakerRequest => translate('speaker_request');
  String get requestToSpeak => translate('request_to_speak');
  String get tapButtonToRequest => translate('tap_button_to_request');
  String get requestSentToAdmin => translate('request_sent_to_admin');
  String get requestPending => translate('request_pending');
  String get yourPositionInQueue => translate('your_position_in_queue');
  String get pleaseWaitForPermission => translate('please_wait_for_permission');
  String get cancelRequest => translate('cancel_request');
  String get requestCancelled => translate('request_cancelled');
  String get micOn => translate('mic_on');
  String get youAreCurrentlySpeaking => translate('you_are_currently_speaking');
  String get speakingTime => translate('speaking_time');
  String get turnOffMic => translate('turn_off_mic');
  String get microphoneTurnedOff => translate('microphone_turned_off');

  // Admin Dashboard
  String get welcomeBackAdmin => translate('welcome_back_admin');
  String get heresWhatsHappening => translate('heres_whats_happening');
  String get activeSessions => translate('active_sessions');
  String get currentVotes => translate('current_votes');
  String get startVotingSession => translate('start_voting_session');
  String get beginNewVotingSession => translate('begin_new_voting_session');
  String get createNewSession => translate('create_new_session');
  String get scheduleNewSession => translate('schedule_new_session');
  String get uploadDocumentAction => translate('upload_document_action');
  String get addMeetingMaterials => translate('add_meeting_materials');
  String get viewReports => translate('view_reports');
  String get checkAttendanceReports => translate('check_attendance_reports');

  // Sessions Management
  String get sessionsManagement => translate('sessions_management');
  String get noSessionsAvailable => translate('no_sessions_available');
  String get loadingSessions => translate('loading_sessions');
  String get active => translate('active');
  String get editFeatureComingSoon => translate('edit_feature_coming_soon');
  String get deleteFeatureComingSoon => translate('delete_feature_coming_soon');
  String get addSession => translate('add_session');
  String get createSessionComingSoon => translate('create_session_coming_soon');

  // Members Management
  String get searchMembers => translate('search_members');
  String get noMembersFound => translate('no_members_found');
  String get loadingMembers => translate('loading_members');
  String get seat => translate('seat');
  String get addMemberComingSoon => translate('add_member_coming_soon');
  String get grantMic => translate('grant_mic');
  String get revokeMic => translate('revoke_mic');
  String get microphoneGrantedTo => translate('microphone_granted_to');
  String get microphoneRevokedFrom => translate('microphone_revoked_from');

  // Common Messages
  String get comingSoon => translate('coming_soon');
  String get featureComingSoon => translate('feature_coming_soon');

  // Voting Control Admin
  String get votingControl_title => translate('voting_control_title');
  String get currentVotingSession => translate('current_voting_session');
  String get liveResults => translate('live_results');
  String get noActiveVotingSession => translate('no_active_voting_session');
  String get startNewVotingSession => translate('start_new_voting_session');
  String get newVoting => translate('new_voting');
  String get createVotingSessionComingSoon =>
      translate('create_voting_session_coming_soon');
  String get loadingVotingData => translate('loading_voting_data');

  // Admin Documents
  String get documentsManagement => translate('documents_management');
  String get noDocumentsUploaded => translate('no_documents_uploaded');
  String get uploadDocumentTitle => translate('upload_document_title');
  String get documentUploaded => translate('document_uploaded');
  String get errorPickingFile => translate('error_picking_file');
  String get deleteDocument => translate('delete_document');
  String get confirmDeleteDocument => translate('confirm_delete_document');
  String get documentDeleted => translate('document_deleted');
  String get assignToMembers => translate('assign_to_members');

  // Attendance Admin
  String get attendanceTitle => translate('attendance_title');
  String get export => translate('export');
  String get exportFeatureComingSoon => translate('export_feature_coming_soon');
  String get rate => translate('rate');
  String get noAttendanceData => translate('no_attendance_data');
  String get loadingAttendanceData => translate('loading_attendance_data');
  String get checkedInAt => translate('checked_in_at');
  String get notCheckedIn => translate('not_checked_in');

  // Reports Admin
  String get reportsTitle => translate('reports_title');
  String get sessionReport => translate('session_report');
  String get votingReport => translate('voting_report');
  String get attendanceReport => translate('attendance_report');
  String get attendanceOverview => translate('attendance_overview');
  String get total => translate('total');
  String get noVotingHistoryAvailable =>
      translate('no_voting_history_available');
  String get totalVotesLabel => translate('total_votes_label');
  String get exportPdf => translate('export_pdf');
  String get exportPdfComingSoon => translate('export_pdf_coming_soon');

  // Voting Screen Member
  String get noActiveVotingSession_member =>
      translate('no_active_voting_session_member');
  String get pleaseWaitForVoting => translate('please_wait_for_voting');
  String get confirmYourVote => translate('confirm_your_vote');
  String get voteSubmittedSuccessfully =>
      translate('vote_submitted_successfully');
  String get confirm => translate('confirm');
  String get youVoted => translate('you_voted');
  String get votes => translate('votes');
  String get loadingVotingSession => translate('loading_voting_session');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// English Strings
const Map<String, String> _enStrings = {
  // Common
  'app_name': 'Conference Management',
  'ok': 'OK',
  'cancel': 'Cancel',
  'save': 'Save',
  'delete': 'Delete',
  'edit': 'Edit',
  'search': 'Search',
  'filter': 'Filter',
  'refresh': 'Refresh',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'close': 'Close',
  'yes': 'Yes',
  'no': 'No',
  'abstain': 'Abstain',

  // Language
  'language': 'Language',
  'english': 'English',
  'arabic': 'العربية',
  'select_language': 'Select Language',

  // Auth
  'login': 'Login',
  'logout': 'Logout',
  'username': 'Username',
  'password': 'Password',
  'enter_username': 'Enter your username',
  'enter_password': 'Enter your password',
  'welcome_to': 'Welcome to the',
  'smart_conference_system': 'Smart Conference System',
  'secure_government_conference_management':
      'Secure Government Conference Management',
  'demo_credentials': 'Demo Credentials',
  'member': 'Member',
  'admin': 'Admin',
  'invalid_credentials': 'Invalid username or password',
  'enter_username_and_password': 'Please enter username and password',

  // Navigation
  'home': 'Home',
  'agenda': 'Agenda',
  'voting': 'Voting',
  'documents': 'Documents',
  'chat': 'Chat',
  'speaker': 'Speaker',
  'profile': 'Profile',
  'dashboard': 'Dashboard',
  'sessions': 'Sessions',
  'members': 'Members',
  'voting_control': 'Voting Control',
  'attendance': 'Attendance',
  'reports': 'Reports',
  'settings': 'Settings',

  // Home
  'welcome': 'Welcome',
  'current_session': 'Current Session',
  'active_voting': 'Active Voting',
  'upcoming_agenda': 'Upcoming Agenda',
  'quick_actions': 'Quick Actions',
  'view_full_agenda': 'View Full Agenda',
  'view_documents': 'View Documents',
  'join_chat': 'Join Chat',

  // Agenda
  'agenda_items': 'Agenda Items',
  'ongoing': 'Ongoing',
  'upcoming': 'Upcoming',
  'completed': 'Completed',
  'all_agenda': 'All',
  'speaker_label': 'Speaker',
  'start_time': 'Start Time',
  'end_time': 'End Time',
  'status': 'Status',

  // Voting
  'current_voting': 'Current Voting',
  'voting_history': 'Voting History',
  'cast_your_vote': 'Cast Your Vote',
  'vote_yes': 'Yes',
  'vote_no': 'No',
  'vote_abstain': 'Abstain',
  'voting_results': 'Voting Results',
  'total_votes': 'Total Votes',
  'voting_ended': 'Voting Ended',
  'voting_active': 'Voting Active',
  'your_vote': 'Your Vote',
  'not_voted_yet': 'Not voted yet',

  // Documents
  'recent_documents': 'Recent Documents',
  'upload_document': 'Upload Document',
  'download_document': 'Download',
  'uploaded_by': 'Uploaded by',
  'uploaded_at': 'Uploaded at',
  'file_size': 'Size',
  'choose_file': 'Choose File',
  'select_file': 'Select File',
  'document_visibility': 'Document Visibility',
  'visible_to_all': 'Visible to All Members',
  'visible_to_admin_only': 'Visible to Admin Only',
  'all_members': 'All Members',
  'admin_only': 'Admin Only',
  'uploading': 'Uploading...',
  'upload_success': 'Document uploaded successfully',
  'upload_failed': 'Failed to upload document',
  'no_file_selected': 'No file selected',
  'please_select_file': 'Please select a file to upload',
  'upload': 'Upload',

  // Chat
  'conference_chat': 'Conference Chat',
  'type_message': 'Type a message...',
  'send_message': 'Send',
  'no_messages': 'No messages yet',

  // Speaker
  'request_microphone': 'Request Microphone',
  'microphone_active': 'Microphone Active',
  'microphone_requested': 'Request Pending',
  'release_microphone': 'Release Microphone',
  'active_speakers': 'Active Speakers',
  'speaker_queue': 'Speaker Queue',

  // Profile
  'personal_info': 'Personal Information',
  'name': 'Name',
  'email': 'Email',
  'role': 'Role',
  'title': 'Title',
  'seat_number': 'Seat Number',
  'preferences': 'Preferences',
  'change_password': 'Change Password',

  // Admin Dashboard
  'admin_dashboard': 'Admin Dashboard',
  'total_members': 'Total Members',
  'present_members': 'Present',
  'absent_members': 'Absent',
  'active_session': 'Active Session',
  'start_session': 'Start Session',
  'end_session': 'End Session',
  'system_overview': 'System Overview',

  // Sessions Management
  'session_management': 'Session Management',
  'create_session': 'Create Session',
  'edit_session': 'Edit Session',
  'delete_session': 'Delete Session',
  'session_title': 'Session Title',
  'session_description': 'Description',
  'session_speaker': 'Speaker',

  // Members Management
  'members_management': 'Members Management',
  'add_member': 'Add Member',
  'edit_member': 'Edit Member',
  'delete_member': 'Delete Member',
  'member_details': 'Member Details',
  'present': 'Present',
  'absent': 'Absent',

  // Voting Control
  'create_voting': 'Create Voting',
  'end_voting': 'End Voting',
  'voting_question': 'Question',
  'voting_title': 'Voting Title',
  'start_voting': 'Start Voting',

  // Attendance
  'attendance_tracking': 'Attendance Tracking',
  'check_in_time': 'Check-in Time',
  'attendance_rate': 'Attendance Rate',

  // Reports
  'generate_report': 'Generate Report',
  'export_report': 'Export Report',
  'session_reports': 'Session Reports',
  'voting_reports': 'Voting Reports',
  'attendance_reports': 'Attendance Reports',

  // Greetings
  'good_morning': 'Good morning',
  'good_afternoon': 'Good afternoon',
  'good_evening': 'Good evening',

  // Member Home Screen
  'quick_access': 'Quick Access',
  'todays_agenda': 'Today\'s Agenda',
  'ongoing_label': 'ONGOING: ',
  'next': 'Next',
  'voting_status': 'Voting Status',
  'no_active_voting': 'No active voting',
  'vote_submitted': 'Vote submitted',
  'vote_now': 'Vote now!',
  'meeting_materials': 'Meeting materials',
  'no_active_session': 'No Active Session',
  'no_sessions_currently':
      'There are no active sessions currently. Please check back later.',
  'time_remaining': 'Time Remaining',
  'enroll_in_session': 'Enroll in Session',
  'join_voting': 'Join Voting',
  'voting_ends_in': 'Voting ends in',
  'active_decision': 'Active Decision',
  'no_active_decision': 'No active decision',

  // Agenda Screen
  'all': 'All',
  'no_agenda_items': 'No agenda items',
  'attended': 'Attended',
  'loading_agenda': 'Loading agenda...',
  'mark_attendance': 'Mark Attendance',
  'attendance_marked': 'Attendance marked',
  'description': 'Description',
  'time': 'Time',
  'date': 'Date',

  // Documents Screen
  'no_documents_available': 'No Documents Available',
  'loading_documents': 'Loading documents...',
  'document_viewer': 'Document Viewer',
  'mock_viewer_for_prototype': 'Mock viewer for prototype',
  'zoom': 'Zoom',
  'highlight': 'Highlight',
  'note': 'Note',
  'download': 'Download',
  'share': 'Share',
  'download_feature_coming_soon': 'Download feature coming soon',
  'share_feature_coming_soon': 'Share feature coming soon',
  'mb': 'MB',

  // Chat Screen
  'group_chat': 'Group Chat',
  'no_messages_yet': 'No messages yet',
  'loading_messages': 'Loading messages...',
  'type_a_message': 'Type a message...',

  // Speaker Screen
  'speaker_request': 'Speaker Request',
  'request_to_speak': 'Request to Speak',
  'tap_button_to_request':
      'Tap the button below to request permission to speak',
  'request_sent_to_admin': 'Request sent to administrator',
  'request_pending': 'Request Pending',
  'your_position_in_queue': 'Your position in queue',
  'please_wait_for_permission':
      'Please wait for the administrator to grant you permission',
  'cancel_request': 'Cancel Request',
  'request_cancelled': 'Request cancelled',
  'mic_on': 'MIC ON',
  'you_are_currently_speaking': 'You are currently speaking',
  'speaking_time': 'Speaking Time',
  'turn_off_mic': 'Turn Off Mic',
  'microphone_turned_off': 'Microphone turned off',

  // Admin Dashboard
  'welcome_back_admin': 'Welcome back, Admin',
  'heres_whats_happening': 'Here\'s what\'s happening today',
  'active_sessions': 'Active Sessions',
  'current_votes': 'Current Votes',
  'start_voting_session': 'Start Voting Session',
  'begin_new_voting_session': 'Begin a new voting session',
  'create_new_session': 'Create New Session',
  'schedule_new_session': 'Schedule a new meeting session',
  'upload_document_action': 'Upload Document',
  'add_meeting_materials': 'Add meeting materials',
  'view_reports': 'View Reports',
  'check_attendance_reports': 'Check attendance and voting reports',

  // Sessions Management
  'sessions_management': 'Sessions Management',
  'no_sessions_available': 'No sessions available',
  'loading_sessions': 'Loading sessions...',
  'active': 'ACTIVE',
  'edit_feature_coming_soon': 'Edit feature coming soon',
  'delete_feature_coming_soon': 'Delete feature coming soon',
  'add_session': 'Add Session',
  'create_session_coming_soon': 'Create session feature coming soon',

  // Members Management
  'search_members': 'Search members...',
  'no_members_found': 'No members found',
  'loading_members': 'Loading members...',
  'seat': 'Seat',
  'add_member_coming_soon': 'Add member feature coming soon',
  'grant_mic': 'Grant Mic',
  'revoke_mic': 'Revoke Mic',
  'microphone_granted_to': 'Microphone granted to',
  'microphone_revoked_from': 'Microphone revoked from',

  // Common Messages
  'coming_soon': 'Coming soon',
  'feature_coming_soon': 'Feature coming soon',

  // Voting Control Admin
  'voting_control_title': 'Voting Control',
  'current_voting_session': 'Current Voting Session',
  'live_results': 'Live Results',
  'no_active_voting_session': 'No Active Voting Session',
  'start_new_voting_session': 'Start a new voting session to see results',
  'new_voting': 'New Voting',
  'create_voting_session_coming_soon':
      'Create voting session feature coming soon',
  'loading_voting_data': 'Loading voting data...',

  // Admin Documents
  'documents_management': 'Documents Management',
  'no_documents_uploaded': 'No documents uploaded',
  'upload_document_title': 'Upload Document',
  'document_uploaded': 'Document uploaded successfully',
  'error_picking_file': 'Error picking file',
  'delete_document': 'Delete Document',
  'confirm_delete_document': 'Are you sure you want to delete this document?',
  'document_deleted': 'Document deleted',
  'assign_to_members': 'Assign to Members',

  // Attendance Admin
  'attendance_title': 'Attendance',
  'export': 'Export',
  'export_feature_coming_soon': 'Export feature coming soon',
  'rate': 'Rate',
  'no_attendance_data': 'No attendance data',
  'loading_attendance_data': 'Loading attendance...',
  'checked_in_at': 'Checked in at',
  'not_checked_in': 'Not checked in',

  // Reports Admin
  'reports_title': 'Reports',
  'session_report': 'Session Report',
  'voting_report': 'Voting Report',
  'attendance_report': 'Attendance Report',
  'attendance_overview': 'Attendance Overview',
  'total': 'Total',
  'no_voting_history_available': 'No voting history available',
  'total_votes_label': 'Total votes',
  'export_pdf': 'Export PDF',
  'export_pdf_coming_soon': 'Export PDF feature coming soon',

  // Voting Screen Member
  'no_active_voting_session_member': 'No Active Voting Session',
  'please_wait_for_voting':
      'Please wait for the administrator to start a voting session',
  'confirm_your_vote': 'Confirm Your Vote',
  'vote_submitted_successfully': 'Vote submitted successfully!',
  'confirm': 'Confirm',
  'you_voted': 'You Voted',
  'votes': 'votes',
  'loading_voting_session': 'Loading voting session...',
};

// Arabic Strings
const Map<String, String> _arStrings = {
  // Common
  'app_name': 'إدارة المؤتمرات',
  'ok': 'موافق',
  'cancel': 'إلغاء',
  'save': 'حفظ',
  'delete': 'حذف',
  'edit': 'تعديل',
  'search': 'بحث',
  'filter': 'تصفية',
  'refresh': 'تحديث',
  'loading': 'جاري التحميل...',
  'error': 'خطأ',
  'success': 'نجح',
  'close': 'إغلاق',
  'yes': 'نعم',
  'no': 'لا',
  'abstain': 'امتناع',

  // Language
  'language': 'اللغة',
  'english': 'English',
  'arabic': 'العربية',
  'select_language': 'اختر اللغة',

  // Auth
  'login': 'تسجيل الدخول',
  'logout': 'تسجيل الخروج',
  'username': 'اسم المستخدم',
  'password': 'كلمة المرور',
  'enter_username': 'أدخل اسم المستخدم',
  'enter_password': 'أدخل كلمة المرور',
  'welcome_to': 'مرحباً بك في',
  'smart_conference_system': 'نظام المؤتمرات الذكي',
  'secure_government_conference_management': 'إدارة مؤتمرات حكومية آمنة',
  'demo_credentials': 'بيانات تجريبية',
  'member': 'عضو',
  'admin': 'مدير',
  'invalid_credentials': 'اسم المستخدم أو كلمة المرور غير صحيحة',
  'enter_username_and_password': 'الرجاء إدخال اسم المستخدم وكلمة المرور',

  // Navigation
  'home': 'الرئيسية',
  'agenda': 'جدول الأعمال',
  'voting': 'التصويت',
  'documents': 'المستندات',
  'chat': 'المحادثة',
  'speaker': 'المتحدث',
  'profile': 'الملف الشخصي',
  'dashboard': 'لوحة التحكم',
  'sessions': 'الجلسات',
  'members': 'الأعضاء',
  'voting_control': 'التحكم بالتصويت',
  'attendance': 'الحضور',
  'reports': 'التقارير',
  'settings': 'الإعدادات',

  // Home
  'welcome': 'مرحباً',
  'current_session': 'الجلسة الحالية',
  'active_voting': 'التصويت النشط',
  'upcoming_agenda': 'جدول الأعمال القادم',
  'quick_actions': 'إجراءات سريعة',
  'view_full_agenda': 'عرض جدول الأعمال الكامل',
  'view_documents': 'عرض المستندات',
  'join_chat': 'الانضمام للمحادثة',

  // Agenda
  'agenda_items': 'بنود جدول الأعمال',
  'ongoing': 'جارية',
  'upcoming': 'قادمة',
  'completed': 'مكتملة',
  'all_agenda': 'الكل',
  'speaker_label': 'المتحدث',
  'start_time': 'وقت البدء',
  'end_time': 'وقت الانتهاء',
  'status': 'الحالة',

  // Voting
  'current_voting': 'التصويت الحالي',
  'voting_history': 'سجل التصويت',
  'cast_your_vote': 'أدلِ بصوتك',
  'vote_yes': 'نعم',
  'vote_no': 'لا',
  'vote_abstain': 'امتناع',
  'voting_results': 'نتائج التصويت',
  'total_votes': 'إجمالي الأصوات',
  'voting_ended': 'انتهى التصويت',
  'voting_active': 'التصويت نشط',
  'your_vote': 'صوتك',
  'not_voted_yet': 'لم تصوت بعد',

  // Documents
  'recent_documents': 'المستندات الحديثة',
  'upload_document': 'رفع مستند',
  'download_document': 'تحميل',
  'uploaded_by': 'رفع بواسطة',
  'uploaded_at': 'رفع في',
  'file_size': 'الحجم',
  'choose_file': 'اختر ملف',
  'select_file': 'اختر ملف',
  'document_visibility': 'مستوى رؤية المستند',
  'visible_to_all': 'مرئي لجميع الأعضاء',
  'visible_to_admin_only': 'مرئي للمدير فقط',
  'all_members': 'جميع الأعضاء',
  'admin_only': 'المدير فقط',
  'uploading': 'جاري الرفع...',
  'upload_success': 'تم رفع المستند بنجاح',
  'upload_failed': 'فشل رفع المستند',
  'no_file_selected': 'لم يتم اختيار ملف',
  'please_select_file': 'الرجاء اختيار ملف للرفع',
  'upload': 'رفع',

  // Chat
  'conference_chat': 'محادثة المؤتمر',
  'type_message': 'اكتب رسالة...',
  'send_message': 'إرسال',
  'no_messages': 'لا توجد رسائل بعد',

  // Speaker
  'request_microphone': 'طلب الميكروفون',
  'microphone_active': 'الميكروفون نشط',
  'microphone_requested': 'الطلب معلق',
  'release_microphone': 'إطلاق الميكروفون',
  'active_speakers': 'المتحدثون النشطون',
  'speaker_queue': 'قائمة المتحدثين',

  // Profile
  'personal_info': 'المعلومات الشخصية',
  'name': 'الاسم',
  'email': 'البريد الإلكتروني',
  'role': 'الدور',
  'title': 'المسمى الوظيفي',
  'seat_number': 'رقم المقعد',
  'preferences': 'التفضيلات',
  'change_password': 'تغيير كلمة المرور',

  // Admin Dashboard
  'admin_dashboard': 'لوحة تحكم المدير',
  'total_members': 'إجمالي الأعضاء',
  'present_members': 'حاضر',
  'absent_members': 'غائب',
  'active_session': 'الجلسة النشطة',
  'start_session': 'بدء الجلسة',
  'end_session': 'إنهاء الجلسة',
  'system_overview': 'نظرة عامة على النظام',

  // Sessions Management
  'session_management': 'إدارة الجلسات',
  'create_session': 'إنشاء جلسة',
  'edit_session': 'تعديل الجلسة',
  'delete_session': 'حذف الجلسة',
  'session_title': 'عنوان الجلسة',
  'session_description': 'الوصف',
  'session_speaker': 'المتحدث',

  // Members Management
  'members_management': 'إدارة الأعضاء',
  'add_member': 'إضافة عضو',
  'edit_member': 'تعديل العضو',
  'delete_member': 'حذف العضو',
  'member_details': 'تفاصيل العضو',
  'present': 'حاضر',
  'absent': 'غائب',

  // Voting Control
  'create_voting': 'إنشاء تصويت',
  'end_voting': 'إنهاء التصويت',
  'voting_question': 'السؤال',
  'voting_title': 'عنوان التصويت',
  'start_voting': 'بدء التصويت',

  // Attendance
  'attendance_tracking': 'تتبع الحضور',
  'check_in_time': 'وقت الحضور',
  'attendance_rate': 'نسبة الحضور',

  // Reports
  'generate_report': 'إنشاء تقرير',
  'export_report': 'تصدير التقرير',
  'session_reports': 'تقارير الجلسات',
  'voting_reports': 'تقارير التصويت',
  'attendance_reports': 'تقارير الحضور',

  // Greetings
  'good_morning': 'صباح الخير',
  'good_afternoon': 'مساء الخير',
  'good_evening': 'مساء الخير',

  // Member Home Screen
  'quick_access': 'وصول سريع',
  'todays_agenda': 'جدول اليوم',
  'ongoing_label': 'جارية: ',
  'next': 'التالي',
  'voting_status': 'حالة التصويت',
  'no_active_voting': 'لا يوجد تصويت نشط',
  'vote_submitted': 'تم إرسال الصوت',
  'vote_now': 'صوّت الآن!',
  'meeting_materials': 'مواد الاجتماع',
  'no_active_session': 'لا توجد جلسة نشطة',
  'no_sessions_currently': 'لا توجد جلسات نشطة حالياً. يرجى المحاولة لاحقاً.',
  'time_remaining': 'الوقت المتبقي',
  'enroll_in_session': 'الانضمام للجلسة',
  'join_voting': 'انضم للتصويت',
  'voting_ends_in': 'ينتهي التصويت في',
  'active_decision': 'القرار النشط',
  'no_active_decision': 'لا يوجد قرار نشط',

  // Agenda Screen
  'all': 'الكل',
  'no_agenda_items': 'لا توجد بنود',
  'attended': 'حضر',
  'loading_agenda': 'جاري تحميل جدول الأعمال...',
  'mark_attendance': 'تسجيل الحضور',
  'attendance_marked': 'تم تسجيل الحضور',
  'description': 'الوصف',
  'time': 'الوقت',
  'date': 'التاريخ',

  // Documents Screen
  'no_documents_available': 'لا توجد مستندات متاحة',
  'loading_documents': 'جاري تحميل المستندات...',
  'document_viewer': 'عارض المستندات',
  'mock_viewer_for_prototype': 'عارض تجريبي للنموذج الأولي',
  'zoom': 'تكبير',
  'highlight': 'تمييز',
  'note': 'ملاحظة',
  'download': 'تحميل',
  'share': 'مشاركة',
  'download_feature_coming_soon': 'ميزة التحميل قريباً',
  'share_feature_coming_soon': 'ميزة المشاركة قريباً',
  'mb': 'ميجابايت',

  // Chat Screen
  'group_chat': 'محادثة جماعية',
  'no_messages_yet': 'لا توجد رسائل بعد',
  'loading_messages': 'جاري تحميل الرسائل...',
  'type_a_message': 'اكتب رسالة...',

  // Speaker Screen
  'speaker_request': 'طلب التحدث',
  'request_to_speak': 'طلب الإذن بالتحدث',
  'tap_button_to_request': 'اضغط على الزر أدناه لطلب الإذن بالتحدث',
  'request_sent_to_admin': 'تم إرسال الطلب إلى المدير',
  'request_pending': 'الطلب معلق',
  'your_position_in_queue': 'موقعك في الطابور',
  'please_wait_for_permission': 'يرجى الانتظار حتى يمنحك المدير الإذن',
  'cancel_request': 'إلغاء الطلب',
  'request_cancelled': 'تم إلغاء الطلب',
  'mic_on': 'الميكروفون مفتوح',
  'you_are_currently_speaking': 'أنت تتحدث الآن',
  'speaking_time': 'وقت التحدث',
  'turn_off_mic': 'إغلاق الميكروفون',
  'microphone_turned_off': 'تم إغلاق الميكروفون',

  // Admin Dashboard
  'welcome_back_admin': 'مرحباً بعودتك، مدير',
  'heres_whats_happening': 'إليك ما يحدث اليوم',
  'active_sessions': 'الجلسات النشطة',
  'current_votes': 'الأصوات الحالية',
  'start_voting_session': 'بدء جلسة تصويت',
  'begin_new_voting_session': 'بدء جلسة تصويت جديدة',
  'create_new_session': 'إنشاء جلسة جديدة',
  'schedule_new_session': 'جدولة جلسة اجتماع جديدة',
  'upload_document_action': 'رفع مستند',
  'add_meeting_materials': 'إضافة مواد الاجتماع',
  'view_reports': 'عرض التقارير',
  'check_attendance_reports': 'التحقق من تقارير الحضور والتصويت',

  // Sessions Management
  'sessions_management': 'إدارة الجلسات',
  'no_sessions_available': 'لا توجد جلسات متاحة',
  'loading_sessions': 'جاري تحميل الجلسات...',
  'active': 'نشط',
  'edit_feature_coming_soon': 'ميزة التعديل قريباً',
  'delete_feature_coming_soon': 'ميزة الحذف قريباً',
  'add_session': 'إضافة جلسة',
  'create_session_coming_soon': 'ميزة إنشاء الجلسة قريباً',

  // Members Management
  'search_members': 'البحث عن الأعضاء...',
  'no_members_found': 'لم يتم العثور على أعضاء',
  'loading_members': 'جاري تحميل الأعضاء...',
  'seat': 'مقعد',
  'add_member_coming_soon': 'ميزة إضافة عضو قريباً',
  'grant_mic': 'منح الميكروفون',
  'revoke_mic': 'سحب الميكروفون',
  'microphone_granted_to': 'تم منح الميكروفون لـ',
  'microphone_revoked_from': 'تم سحب الميكروفون من',

  // Common Messages
  'coming_soon': 'قريباً',
  'feature_coming_soon': 'الميزة قريباً',

  // Voting Control Admin
  'voting_control_title': 'التحكم بالتصويت',
  'current_voting_session': 'جلسة التصويت الحالية',
  'live_results': 'النتائج المباشرة',
  'no_active_voting_session': 'لا توجد جلسة تصويت نشطة',
  'start_new_voting_session': 'ابدأ جلسة تصويت جديدة لعرض النتائج',
  'new_voting': 'تصويت جديد',
  'create_voting_session_coming_soon': 'ميزة إنشاء جلسة التصويت قريباً',
  'loading_voting_data': 'جاري تحميل بيانات التصويت...',

  // Admin Documents
  'documents_management': 'إدارة المستندات',
  'no_documents_uploaded': 'لا توجد مستندات مرفوعة',
  'upload_document_title': 'رفع مستند',
  'document_uploaded': 'تم رفع المستند بنجاح',
  'error_picking_file': 'خطأ في اختيار الملف',
  'delete_document': 'حذف المستند',
  'confirm_delete_document': 'هل أنت متأكد من حذف هذا المستند؟',
  'document_deleted': 'تم حذف المستند',
  'assign_to_members': 'تعيين للأعضاء',

  // Attendance Admin
  'attendance_title': 'الحضور',
  'export': 'تصدير',
  'export_feature_coming_soon': 'ميزة التصدير قريباً',
  'rate': 'النسبة',
  'no_attendance_data': 'لا توجد بيانات حضور',
  'loading_attendance_data': 'جاري تحميل الحضور...',
  'checked_in_at': 'سجل الحضور في',
  'not_checked_in': 'لم يسجل الحضور',

  // Reports Admin
  'reports_title': 'التقارير',
  'session_report': 'تقرير الجلسة',
  'voting_report': 'تقرير التصويت',
  'attendance_report': 'تقرير الحضور',
  'attendance_overview': 'نظرة عامة على الحضور',
  'total': 'الإجمالي',
  'no_voting_history_available': 'لا يوجد سجل تصويت متاح',
  'total_votes_label': 'إجمالي الأصوات',
  'export_pdf': 'تصدير PDF',
  'export_pdf_coming_soon': 'ميزة تصدير PDF قريباً',

  // Voting Screen Member
  'no_active_voting_session_member': 'لا توجد جلسة تصويت نشطة',
  'please_wait_for_voting': 'يرجى الانتظار حتى يبدأ المدير جلسة تصويت',
  'confirm_your_vote': 'تأكيد صوتك',
  'vote_submitted_successfully': 'تم إرسال الصوت بنجاح!',
  'confirm': 'تأكيد',
  'you_voted': 'لقد صوّت',
  'votes': 'صوت',
  'loading_voting_session': 'جاري تحميل جلسة التصويت...',
};

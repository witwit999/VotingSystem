class ApiConstants {
  // Base URLs for different environments
  static const String devBaseUrl = 'http://192.168.1.110:8080';
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8080';
  static const String iosSimulatorBaseUrl = 'http://192.168.1.110:8080';
  static const String physicalDeviceBaseUrl = 'http://192.168.1.110:8080';

  // Current base URL - change based on your environment
  // Use devBaseUrl for iOS Simulator
  // Use androidEmulatorBaseUrl for Android Emulator
  // Use physicalDeviceBaseUrl for Physical Devices
  static const String baseUrl =
      iosSimulatorBaseUrl; // ← Currently set for iOS Simulator

  // WebSocket endpoint (update based on your environment)
  static const String wsUrl = 'ws://192.168.1.110:8080/ws'; // For iOS Simulator
  // static const String wsUrl = 'ws://10.0.2.2:8080/ws'; // For Android Emulator
  // static const String wsUrl = 'ws://192.168.1.100:8080/ws'; // For Physical Device

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String meEndpoint = '/auth/me';

  // Session endpoints
  static const String sessionsEndpoint = '/sessions';
  static String sessionDetailsEndpoint(String sessionId) =>
      '/sessions/$sessionId';
  static String sessionJoinEndpoint(String sessionId) =>
      '/sessions/$sessionId/join';
  static String sessionLeaveEndpoint(String sessionId) =>
      '/sessions/$sessionId/leave';
  static String sessionOpenEndpoint(String sessionId) =>
      '/sessions/$sessionId/open';
  static String sessionPauseEndpoint(String sessionId) =>
      '/sessions/$sessionId/pause';
  static String sessionCloseEndpoint(String sessionId) =>
      '/sessions/$sessionId/close';
  static String sessionArchiveEndpoint(String sessionId) =>
      '/sessions/$sessionId/archive';

  // Decision endpoints
  static String sessionDecisionsEndpoint(String sessionId) =>
      '/sessions/$sessionId/decisions';
  static String decisionDetailsEndpoint(String decisionId) =>
      '/decisions/$decisionId';
  static String decisionOpenEndpoint(String decisionId) =>
      '/decisions/$decisionId/open';
  static String decisionCloseEndpoint(String decisionId) =>
      '/decisions/$decisionId/close';
  static String decisionVotesEndpoint(String decisionId) =>
      '/decisions/$decisionId/votes';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

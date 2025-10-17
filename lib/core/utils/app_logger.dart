import 'package:logger/logger.dart';

/// Centralized logging utility for the application
class AppLogger {
  // Simple logger with minimal formatting for clean console output
  static final Logger _logger = Logger(
    printer: SimplePrinter(colors: false, printTime: true),
  );

  // Alternative: Pretty printer (uncomment to use)
  // static final Logger _logger = Logger(
  //   printer: PrettyPrinter(
  //     methodCount: 2,
  //     errorMethodCount: 8,
  //     lineLength: 120,
  //     colors: false,
  //     printEmojis: true,
  //     dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  //   ),
  // );

  /// Log debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal/critical message
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log trace message (very verbose)
  static void trace(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }
}

import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static Logger? _logger;

  static Logger get logger {
    _logger ??= Logger(
      printer: SimplePrinter(
        printTime: false,
        colors: true,
      ),
      level: AppConfig.enableLogging ? Level.warning : Level.nothing,
    );
    return _logger!;
  }

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!AppConfig.enableLogging) return;
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!AppConfig.enableLogging) return;
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.f(message, error: error, stackTrace: stackTrace);
  }
}

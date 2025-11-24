import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart' as app_config;
import 'package:iqra_wave/core/utils/logger.dart';

@lazySingleton
class DeviceSecurityService {
  Future<SecurityCheckResult> performSecurityCheck() async {
    try {
      AppLogger.info('Performing device security check');

      final isJailbroken = await FlutterJailbreakDetection.jailbroken;

      final isDeveloperMode = await FlutterJailbreakDetection.developerMode;

      final result = SecurityCheckResult(
        isSecure: !isJailbroken && !isDeveloperMode,
        isJailbroken: isJailbroken,
        isDeveloperMode: isDeveloperMode,
        timestamp: DateTime.now(),
      );

      _logSecurityCheckResult(result);

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Security check failed', e, stackTrace);

      return SecurityCheckResult(
        isSecure: false,
        isJailbroken: false,
        isDeveloperMode: false,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  Future<bool> shouldAllowAuthentication() async {
    final result = await performSecurityCheck();

    if (!result.isSecure) {
      _logSecurityEvent('Insecure device detected', result);

      // Enterprise policy: Block on production, warn on dev
      if (app_config.AppConfig.environment == app_config.Environment.prod) {
        AppLogger.error(
          'Authentication blocked: Device security check failed',
        );
        return false;
      } else {
        AppLogger.warning(
          'Device security check failed - allowing in ${app_config.AppConfig.environment} mode',
        );
        return true;
      }
    }

    return true;
  }

  /// Log security check result
  void _logSecurityCheckResult(SecurityCheckResult result) {
    if (result.isSecure) {
      AppLogger.info('Device security check passed');
    } else {
      AppLogger.warning(
        'Device security check failed:\n'
        '  Jailbroken: ${result.isJailbroken}\n'
        '  Developer Mode: ${result.isDeveloperMode}\n'
        '  Error: ${result.error ?? "None"}',
      );
    }
  }

  /// Log security event
  void _logSecurityEvent(String message, SecurityCheckResult result) {
    AppLogger.warning(
      '$message:\n'
      '  Environment: ${app_config.AppConfig.environment}\n'
      '  Jailbroken: ${result.isJailbroken}\n'
      '  Developer Mode: ${result.isDeveloperMode}\n'
      '  Timestamp: ${result.timestamp}',
    );

    // TODO: Send to security monitoring service
    // Examples:
    // - Firebase Analytics (security_event)
    // - Sentry with security context
    // - Custom audit log endpoint
  }

  /// Get security recommendations for user
  Future<List<String>> getSecurityRecommendations() async {
    final result = await performSecurityCheck();
    final recommendations = <String>[];

    if (result.isJailbroken) {
      recommendations.add(
        'Your device appears to be jailbroken/rooted. '
        'This may compromise app security.',
      );
    }

    if (result.isDeveloperMode) {
      recommendations.add(
        'Developer mode is enabled. '
        'Consider disabling it for enhanced security.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Your device meets security requirements.',
      );
    }

    return recommendations;
  }

  /// Check if running on emulator (for additional security)
  Future<bool> isEmulator() async {
    try {
      // This can be extended with platform-specific emulator detection
      // For now, use developer mode as a proxy
      return await FlutterJailbreakDetection.developerMode;
    } catch (e) {
      AppLogger.error('Emulator detection failed', e);
      return false;
    }
  }
}

/// Result of device security check
class SecurityCheckResult {
  SecurityCheckResult({
    required this.isSecure,
    required this.isJailbroken,
    required this.isDeveloperMode,
    required this.timestamp,
    this.error,
  });
  final bool isSecure;
  final bool isJailbroken;
  final bool isDeveloperMode;
  final DateTime timestamp;
  final String? error;

  @override
  String toString() {
    return 'SecurityCheckResult(\n'
        '  isSecure: $isSecure,\n'
        '  isJailbroken: $isJailbroken,\n'
        '  isDeveloperMode: $isDeveloperMode,\n'
        '  timestamp: $timestamp,\n'
        '  error: $error\n'
        ')';
  }

  Map<String, dynamic> toJson() {
    return {
      'isSecure': isSecure,
      'isJailbroken': isJailbroken,
      'isDeveloperMode': isDeveloperMode,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
    };
  }
}

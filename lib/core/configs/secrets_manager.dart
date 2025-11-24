import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iqra_wave/core/utils/logger.dart';

class SecretsManager {
  bool _isInitialized = false;
  bool _dotenvLoaded = false;

  Future<void> initialize({String? envFile}) async {
    if (_isInitialized) {
      AppLogger.debug('SecretsManager already initialized');
      return;
    }

    try {
      final fileName = envFile ?? '.env';
      await dotenv.load(fileName: fileName);
      _dotenvLoaded = true;
      _isInitialized = true;

      if (dotenv.env.isEmpty) {
        AppLogger.warning('Warning: .env file loaded but contains no values');
        _dotenvLoaded = false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load .env file: $e', e, stackTrace);
      AppLogger.warning('Continuing without .env file - using defaults');
      _dotenvLoaded = false;
      _isInitialized = true;
    }
  }

  /// Get OAuth client secret
  /// Priority: 1. Dart define, 2. .env file, 3. Exception
  String getOAuthClientSecret() {
    _ensureInitialized();

    // 1. Try compile-time environment variable (--dart-define)
    const envSecret = String.fromEnvironment(
      'OAUTH_CLIENT_SECRET',
    );
    if (envSecret.isNotEmpty) {
      AppLogger.debug('Using OAuth secret from --dart-define');
      return envSecret;
    }

    final dotenvSecret = _dotenvLoaded
        ? dotenv.env['OAUTH_CLIENT_SECRET']
        : null;
    if (dotenvSecret != null && dotenvSecret.isNotEmpty) {
      AppLogger.debug('Using OAuth secret from .env file');
      return dotenvSecret;
    }

    throw Exception(
      'OAuth client secret not configured. '
      'Please set OAUTH_CLIENT_SECRET in .env file or use --dart-define',
    );
  }

  String getOAuthClientId() {
    _ensureInitialized();

    const envId = String.fromEnvironment(
      'OAUTH_CLIENT_ID',
    );
    if (envId.isNotEmpty) {
      return envId;
    }

    final dotenvId = _dotenvLoaded ? dotenv.env['OAUTH_CLIENT_ID'] : null;
    if (dotenvId != null && dotenvId.isNotEmpty) {
      return dotenvId;
    }

    throw Exception(
      'OAuth client ID not configured. '
      'Please set OAUTH_CLIENT_ID in .env file or use --dart-define',
    );
  }

  String getOAuthBaseUrl() {
    _ensureInitialized();

    const envUrl = String.fromEnvironment(
      'OAUTH_BASE_URL',
    );
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    return (_dotenvLoaded ? dotenv.env['OAUTH_BASE_URL'] : null) ??
        'https://prelive-oauth2.quran.foundation';
  }

  /// Get Quran API base URL
  String getQuranApiBaseUrl() {
    _ensureInitialized();

    const envUrl = String.fromEnvironment(
      'QURAN_API_BASE_URL',
    );
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    return (_dotenvLoaded ? dotenv.env['QURAN_API_BASE_URL'] : null) ??
        'https://prelive-api.quran.foundation';
  }

  /// Get environment name
  String getEnvironment() {
    _ensureInitialized();

    const env = String.fromEnvironment(
      'ENVIRONMENT',
    );
    if (env.isNotEmpty) {
      return env;
    }

    return (_dotenvLoaded ? dotenv.env['ENVIRONMENT'] : null) ?? 'dev';
  }

  /// Check if logging is enabled
  bool isLoggingEnabled() {
    _ensureInitialized();

    const enabled = String.fromEnvironment(
      'ENABLE_LOGGING',
    );
    if (enabled.isNotEmpty) {
      return enabled.toLowerCase() == 'true';
    }

    final dotenvEnabled = _dotenvLoaded ? dotenv.env['ENABLE_LOGGING'] : null;
    return dotenvEnabled?.toLowerCase() == 'true';
  }

  /// Check if crashlytics is enabled
  bool isCrashlyticsEnabled() {
    _ensureInitialized();

    const enabled = String.fromEnvironment(
      'ENABLE_CRASHLYTICS',
    );
    if (enabled.isNotEmpty) {
      return enabled.toLowerCase() == 'true';
    }

    final dotenvEnabled = _dotenvLoaded
        ? dotenv.env['ENABLE_CRASHLYTICS']
        : null;
    return dotenvEnabled?.toLowerCase() == 'true';
  }

  /// Check if analytics is enabled
  bool isAnalyticsEnabled() {
    _ensureInitialized();

    const enabled = String.fromEnvironment(
      'ENABLE_ANALYTICS',
    );
    if (enabled.isNotEmpty) {
      return enabled.toLowerCase() == 'true';
    }

    final dotenvEnabled = _dotenvLoaded ? dotenv.env['ENABLE_ANALYTICS'] : null;
    return dotenvEnabled?.toLowerCase() == 'true';
  }

  /// Get Sentry DSN
  String? getSentryDsn() {
    _ensureInitialized();

    const dsn = String.fromEnvironment(
      'SENTRY_DSN',
    );
    if (dsn.isNotEmpty) {
      return dsn;
    }

    final dotenvDsn = _dotenvLoaded ? dotenv.env['SENTRY_DSN'] : null;
    if (dotenvDsn != null && dotenvDsn.isNotEmpty && dotenvDsn != '***') {
      return dotenvDsn;
    }

    return null;
  }

  /// Ensure secrets manager is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'SecretsManager not initialized. '
        'Call initialize() before accessing secrets.',
      );
    }
  }

  /// Get all configuration for debugging (values are masked)
  Map<String, String> getConfigDebugInfo() {
    _ensureInitialized();

    return {
      'environment': getEnvironment(),
      'oauth_base_url': getOAuthBaseUrl(),
      'quran_api_base_url': getQuranApiBaseUrl(),
      'oauth_client_id': _maskSecret(getOAuthClientId()),
      'oauth_client_secret': '***',
      'logging_enabled': isLoggingEnabled().toString(),
      'crashlytics_enabled': isCrashlyticsEnabled().toString(),
      'analytics_enabled': isAnalyticsEnabled().toString(),
      'sentry_configured': (getSentryDsn() != null).toString(),
    };
  }

  /// Mask a secret for logging (show first 4 and last 4 characters)
  String _maskSecret(String secret) {
    if (secret.length <= 8) {
      return '***';
    }
    final start = secret.substring(0, 4);
    final end = secret.substring(secret.length - 4);
    return '$start....$end';
  }
}

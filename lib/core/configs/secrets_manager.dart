import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/utils/logger.dart';

/// Manages application secrets and sensitive configuration
/// Priority: Environment variables > .env file > Defaults
@lazySingleton
class SecretsManager {
  bool _isInitialized = false;

  /// Initialize the secrets manager
  /// Must be called before any secrets are accessed
  Future<void> initialize({String? envFile}) async {
    if (_isInitialized) {
      AppLogger.debug('SecretsManager already initialized');
      return;
    }

    try {
      // Load from .env file
      final fileName = envFile ?? '.env';
      await dotenv.load(fileName: fileName);

      _isInitialized = true;
      AppLogger.info('SecretsManager initialized from $fileName');

      // Log loaded keys (not values) in debug mode
      AppLogger.debug('Loaded env keys: ${dotenv.env.keys.toList()}');
    } catch (e) {
      AppLogger.error('Failed to load .env file', e);
      AppLogger.warning('Continuing without .env file - using defaults');
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
      defaultValue: '',
    );
    if (envSecret.isNotEmpty) {
      AppLogger.debug('Using OAuth secret from --dart-define');
      return envSecret;
    }

    // 2. Try .env file
    final dotenvSecret = dotenv.env['OAUTH_CLIENT_SECRET'];
    if (dotenvSecret != null && dotenvSecret.isNotEmpty) {
      AppLogger.debug('Using OAuth secret from .env file');
      return dotenvSecret;
    }

    // 3. No secret found - throw exception
    throw Exception(
      'OAuth client secret not configured. '
      'Please set OAUTH_CLIENT_SECRET in .env file or use --dart-define',
    );
  }

  /// Get OAuth client ID
  String getOAuthClientId() {
    _ensureInitialized();

    const envId = String.fromEnvironment(
      'OAUTH_CLIENT_ID',
      defaultValue: '',
    );
    if (envId.isNotEmpty) {
      return envId;
    }

    final dotenvId = dotenv.env['OAUTH_CLIENT_ID'];
    if (dotenvId != null && dotenvId.isNotEmpty) {
      return dotenvId;
    }

    throw Exception(
      'OAuth client ID not configured. '
      'Please set OAUTH_CLIENT_ID in .env file or use --dart-define',
    );
  }

  /// Get OAuth base URL
  String getOAuthBaseUrl() {
    _ensureInitialized();

    const envUrl = String.fromEnvironment(
      'OAUTH_BASE_URL',
      defaultValue: '',
    );
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    return dotenv.env['OAUTH_BASE_URL'] ??
           'https://prelive-oauth2.quran.foundation';
  }

  /// Get Quran API base URL
  String getQuranApiBaseUrl() {
    _ensureInitialized();

    const envUrl = String.fromEnvironment(
      'QURAN_API_BASE_URL',
      defaultValue: '',
    );
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    return dotenv.env['QURAN_API_BASE_URL'] ??
           'https://prelive-api.quran.foundation';
  }

  /// Get environment name
  String getEnvironment() {
    _ensureInitialized();

    const env = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: '',
    );
    if (env.isNotEmpty) {
      return env;
    }

    return dotenv.env['ENVIRONMENT'] ?? 'dev';
  }

  /// Check if logging is enabled
  bool isLoggingEnabled() {
    _ensureInitialized();

    const enabled = String.fromEnvironment(
      'ENABLE_LOGGING',
      defaultValue: '',
    );
    if (enabled.isNotEmpty) {
      return enabled.toLowerCase() == 'true';
    }

    final dotenvEnabled = dotenv.env['ENABLE_LOGGING'];
    return dotenvEnabled?.toLowerCase() == 'true';
  }

  /// Check if crashlytics is enabled
  bool isCrashlyticsEnabled() {
    _ensureInitialized();

    const enabled = String.fromEnvironment(
      'ENABLE_CRASHLYTICS',
      defaultValue: '',
    );
    if (enabled.isNotEmpty) {
      return enabled.toLowerCase() == 'true';
    }

    final dotenvEnabled = dotenv.env['ENABLE_CRASHLYTICS'];
    return dotenvEnabled?.toLowerCase() == 'true';
  }

  /// Check if analytics is enabled
  bool isAnalyticsEnabled() {
    _ensureInitialized();

    const enabled = String.fromEnvironment(
      'ENABLE_ANALYTICS',
      defaultValue: '',
    );
    if (enabled.isNotEmpty) {
      return enabled.toLowerCase() == 'true';
    }

    final dotenvEnabled = dotenv.env['ENABLE_ANALYTICS'];
    return dotenvEnabled?.toLowerCase() == 'true';
  }

  /// Get Sentry DSN
  String? getSentryDsn() {
    _ensureInitialized();

    const dsn = String.fromEnvironment(
      'SENTRY_DSN',
      defaultValue: '',
    );
    if (dsn.isNotEmpty) {
      return dsn;
    }

    final dotenvDsn = dotenv.env['SENTRY_DSN'];
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

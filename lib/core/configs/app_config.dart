import 'package:iqra_wave/core/configs/secrets_manager.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  static Environment _environment = Environment.dev;
  static bool _isDebugMode = true;
  static SecretsManager? _secretsManager;

  static Environment get environment => _environment;
  static bool get isDebugMode => _isDebugMode;

  static void initialize(SecretsManager secretsManager) {
    _secretsManager = secretsManager;

    final envString = secretsManager.getEnvironment().toLowerCase();
    switch (envString) {
      case 'dev':
        _environment = Environment.dev;
      case 'staging':
        _environment = Environment.staging;
      case 'prod':
        _environment = Environment.prod;
      default:
        _environment = Environment.dev;
    }

    _isDebugMode = _environment == Environment.dev;
  }

  static void setEnvironment(Environment env) {
    _environment = env;
    _isDebugMode = env == Environment.dev;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://jsonplaceholder.typicode.com';
      case Environment.staging:
        return 'https://jsonplaceholder.typicode.com';
      case Environment.prod:
        return 'https://jsonplaceholder.typicode.com';
    }
  }

  static String get appName {
    switch (_environment) {
      case Environment.dev:
        return 'IqraWave Dev';
      case Environment.staging:
        return 'IqraWave Staging';
      case Environment.prod:
        return 'IqraWave';
    }
  }

  static bool get enableLogging {
    if (_secretsManager != null) {
      return _secretsManager!.isLoggingEnabled();
    }
    return _environment != Environment.prod;
  }

  static String get oauthBaseUrl {
    _ensureInitialized();
    return _secretsManager!.getOAuthBaseUrl();
  }

  static String get quranApiBaseUrl {
    _ensureInitialized();
    return _secretsManager!.getQuranApiBaseUrl();
  }

  static String get oauthClientId {
    _ensureInitialized();
    return _secretsManager!.getOAuthClientId();
  }

  static String get oauthClientSecret {
    _ensureInitialized();
    return _secretsManager!.getOAuthClientSecret();
  }

  static bool get enableCrashlytics {
    if (_secretsManager != null) {
      return _secretsManager!.isCrashlyticsEnabled();
    }
    return false;
  }

  static bool get enableAnalytics {
    if (_secretsManager != null) {
      return _secretsManager!.isAnalyticsEnabled();
    }
    return false;
  }

  static String? get sentryDsn {
    if (_secretsManager != null) {
      return _secretsManager!.getSentryDsn();
    }
    return null;
  }

  static void _ensureInitialized() {
    if (_secretsManager == null) {
      throw Exception(
        'AppConfig not initialized. '
        'Call AppConfig.initialize(secretsManager) before accessing config.',
      );
    }
  }
}

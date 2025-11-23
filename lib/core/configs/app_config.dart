enum Environment { dev, staging, prod }

class AppConfig {
  static Environment _environment = Environment.dev;
  static bool _isDebugMode = true;

  static Environment get environment => _environment;
  static bool get isDebugMode => _isDebugMode;

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

  static bool get enableLogging => _environment != Environment.prod;

  // Quran.Foundation OAuth2 Configuration
  static String get oauthBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://prelive-oauth2.quran.foundation';
      case Environment.staging:
        return 'https://prelive-oauth2.quran.foundation';
      case Environment.prod:
        return 'https://oauth2.quran.foundation';
    }
  }

  static String get quranApiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://prelive-api.quran.foundation';
      case Environment.staging:
        return 'https://prelive-api.quran.foundation';
      case Environment.prod:
        return 'https://api.quran.foundation';
    }
  }

  static String get oauthClientId {
    switch (_environment) {
      case Environment.dev:
      case Environment.staging:
        return '1025e8c6-f978-4186-aed4-7b82b71ec763';
      case Environment.prod:
        return '4d57db73-0de3-4ff9-8fc5-8ff5ecf51a08';
    }
  }

  // NOTE: In production, this should be stored in secure environment variables
  // or retrieved from a secure backend service, never hardcoded
  static String get oauthClientSecret {
    switch (_environment) {
      case Environment.dev:
      case Environment.staging:
        return 'cjBj46-wJJkUr15euqZ1sTfbiC'; // Fixed: wJJk (not wdJk) and euqZ1 (not euqZl)
      case Environment.prod:
        return '4b9rxwZa80dy2l.HUfmSd4fUH7'; // Fixed: dy2l (not dy21)
    }
  }
}

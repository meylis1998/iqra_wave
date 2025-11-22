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
}

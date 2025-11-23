class ApiConstants {
  // Legacy API URLs (JSONPlaceholder - for testing)
  static const String devBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String stagingBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String prodBaseUrl = 'https://jsonplaceholder.typicode.com';

  // Quran.Foundation OAuth2 URLs
  static const String devOAuthUrl = 'https://prelive-oauth2.quran.foundation';
  static const String stagingOAuthUrl = 'https://prelive-oauth2.quran.foundation';
  static const String prodOAuthUrl = 'https://oauth2.quran.foundation';

  // Quran.Foundation API URLs
  static const String devQuranApiUrl = 'https://prelive-api.quran.foundation';
  static const String stagingQuranApiUrl = 'https://prelive-api.quran.foundation';
  static const String prodQuranApiUrl = 'https://api.quran.foundation';

  // Legacy endpoints
  static const String posts = '/posts';
  static const String users = '/users';
  static const String comments = '/comments';
  static const String login = '/login';
  static const String register = '/register';

  // OAuth2 endpoints
  static const String oauth2Token = '/oauth/token';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Quran.Foundation specific headers
  static const String xAuthToken = 'x-auth-token';
  static const String xClientId = 'x-client-id';

  // OAuth2 grant types
  static const String grantTypeClientCredentials = 'client_credentials';
}

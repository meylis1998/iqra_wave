class ApiConstants {
  // Quran.Foundation OAuth2 URLs
  static const String devOAuthUrl = 'https://prelive-oauth2.quran.foundation';
  static const String stagingOAuthUrl = 'https://prelive-oauth2.quran.foundation';
  static const String prodOAuthUrl = 'https://oauth2.quran.foundation';

  // Quran.Foundation API URLs
  static const String devQuranApiUrl = 'https://apis-prelive.quran.foundation';
  static const String stagingQuranApiUrl = 'https://apis-prelive.quran.foundation';
  static const String prodQuranApiUrl = 'https://apis.quran.foundation';

  // OAuth2 endpoints
  static const String oauth2Token = '/oauth2/token';
  static const String oauth2Authorize = '/oauth2/auth';
  static const String oauth2Userinfo = '/userinfo';
  static const String oauth2Logout = '/oauth2/sessions/logout';

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
  static const String grantTypeAuthorizationCode = 'authorization_code';
  static const String grantTypeRefreshToken = 'refresh_token';

  // OAuth2 scopes
  static const String scopeContent = 'content';
  static const String scopeOffline = 'offline';
  static const String scopeOpenId = 'openid';
  static const String scopeProfile = 'profile';
  static const String scopeEmail = 'email';
}

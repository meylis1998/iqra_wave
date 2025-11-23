class StorageConstants {
  // Legacy auth tokens
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';

  // App preferences
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String isFirstLaunch = 'is_first_launch';

  // Secure storage (legacy)
  static const String secureAuthToken = 'secure_auth_token';
  static const String secureRefreshToken = 'secure_refresh_token';

  // Quran.Foundation OAuth2 tokens (secure storage)
  static const String quranFoundationToken = 'quran_foundation_token';
  static const String quranFoundationTokenExpiry = 'quran_foundation_token_expiry';
  static const String quranFoundationClientId = 'quran_foundation_client_id';
}

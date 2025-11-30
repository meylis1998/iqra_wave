enum AuthMode {
  /// Anonymous content browsing using client credentials flow
  /// - No user authentication required
  /// - Access to public content APIs only
  /// - Tokens automatically refreshed
  clientCredentials,

  /// User authenticated session using authorization code + PKCE flow
  /// - User login via browser
  /// - Access to user-specific data and personalized features
  /// - Supports bookmarks, preferences, reading sessions, etc.
  userAuthenticated,
}

extension AuthModeExtension on AuthMode {
  bool get isUserAuthenticated => this == AuthMode.userAuthenticated;

  bool get isClientCredentials => this == AuthMode.clientCredentials;

  String get displayName {
    switch (this) {
      case AuthMode.clientCredentials:
        return 'Anonymous';
      case AuthMode.userAuthenticated:
        return 'Signed In';
    }
  }

  String get description {
    switch (this) {
      case AuthMode.clientCredentials:
        return 'Browsing content without user account';
      case AuthMode.userAuthenticated:
        return 'Full access with personalized features';
    }
  }
}

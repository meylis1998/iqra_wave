import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/error/exceptions.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/data/models/token_response_model.dart';

/// Data source for OAuth2 Authorization Code + PKCE flow
/// Handles user authentication via browser-based OAuth
@lazySingleton
class OAuthAuthorizationCodeDataSource {
  OAuthAuthorizationCodeDataSource(this._appAuth);

  final FlutterAppAuth _appAuth;

  static const String _redirectUri = 'iqrawave://oauth2callback';
  static const List<String> _scopes = [
    'openid',
    'offline',
    'user',
    'bookmark',
    'collection',
    'reading_session',
    'preference',
  ];

  /// Initiates browser-based OAuth login and exchanges code for tokens
  Future<TokenResponseModel> signInWithBrowser() async {
    try {
      AppLogger.info('Initiating OAuth2 Authorization Code + PKCE flow');
      AppLogger.info('Client ID: ${AppConfig.oauthClientId}');
      AppLogger.info('Redirect URI: $_redirectUri');
      AppLogger.info('Scopes: $_scopes');
      AppLogger.info('Authorization endpoint: ${AppConfig.oauthBaseUrl}/oauth2/auth');
      AppLogger.info('Token endpoint: ${AppConfig.oauthBaseUrl}/oauth2/token');

      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AppConfig.oauthClientId,
          _redirectUri,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint:
                '${AppConfig.oauthBaseUrl}/oauth2/auth',
            tokenEndpoint: '${AppConfig.oauthBaseUrl}/oauth2/token',
          ),
          scopes: _scopes,
          promptValues: ['login'],
          // flutter_appauth automatically generates nonce for openid scope
          // and handles PKCE code_challenge/code_verifier
        ),
      );

      if (result == null) {
        AppLogger.warning('User cancelled OAuth2 authorization');
        throw AuthenticationException('User cancelled login');
      }

      if (result.accessToken == null) {
        AppLogger.error('No access token received from OAuth2 server');
        throw OAuth2Exception('No access token received');
      }

      AppLogger.info('OAuth2 authorization successful');
      AppLogger.info('Access token received: ${result.accessToken!.substring(0, 20)}...');
      AppLogger.info('Refresh token: ${result.refreshToken != null ? "present" : "missing"}');
      AppLogger.info('ID token: ${result.idToken != null ? "present" : "missing"}');

      // Convert flutter_appauth response to our TokenResponseModel
      final tokenData = {
        'access_token': result.accessToken!,
        'token_type': result.tokenType ?? 'Bearer',
        'expires_in': result.accessTokenExpirationDateTime != null
            ? result.accessTokenExpirationDateTime!
                .difference(DateTime.now())
                .inSeconds
            : 3600,
        'refresh_token': result.refreshToken,
        'id_token': result.idToken,
        'issuedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      return TokenResponseModel.fromJson(tokenData);
    } on FlutterAppAuthUserCancelledException catch (e) {
      AppLogger.warning('User cancelled OAuth2 flow: $e');
      throw AuthenticationException('User cancelled login');
    } on FlutterAppAuthPlatformException catch (e) {
      AppLogger.error('Platform error during OAuth2 flow: ${e.code} - ${e.message}');
      AppLogger.error('Error details: ${e.details}');
      throw OAuth2Exception('Authentication failed: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during OAuth2 flow: $e');
      AppLogger.error('Stack trace: $stackTrace');
      throw OAuth2Exception('Unexpected error during login: $e');
    }
  }

  /// Refreshes access token using refresh token
  Future<TokenResponseModel> refreshToken(String refreshToken) async {
    try {
      AppLogger.info('Refreshing access token using refresh token');

      final TokenResponse? result = await _appAuth.token(
        TokenRequest(
          AppConfig.oauthClientId,
          _redirectUri,
          refreshToken: refreshToken,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint:
                '${AppConfig.oauthBaseUrl}/oauth2/auth',
            tokenEndpoint: '${AppConfig.oauthBaseUrl}/oauth2/token',
          ),
        ),
      );

      if (result == null || result.accessToken == null) {
        AppLogger.error('Failed to refresh token - no response');
        throw OAuth2Exception('Failed to refresh token');
      }

      AppLogger.info('Token refresh successful');

      final tokenData = {
        'access_token': result.accessToken!,
        'token_type': result.tokenType ?? 'Bearer',
        'expires_in': result.accessTokenExpirationDateTime != null
            ? result.accessTokenExpirationDateTime!
                .difference(DateTime.now())
                .inSeconds
            : 3600,
        'refresh_token': result.refreshToken ?? refreshToken,
        'id_token': result.idToken,
        'issuedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      return TokenResponseModel.fromJson(tokenData);
    } on FlutterAppAuthPlatformException catch (e) {
      AppLogger.error('Platform error during token refresh: ${e.code} - ${e.message}');
      throw OAuth2Exception('Token refresh failed: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during token refresh: $e');
      AppLogger.error('Stack trace: $stackTrace');
      throw OAuth2Exception('Unexpected error during token refresh: $e');
    }
  }

  /// Ends user session by calling logout endpoint
  Future<void> signOut({String? idToken}) async {
    try {
      AppLogger.info('Signing out user');

      final EndSessionResponse? result = await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: _redirectUri,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint:
                '${AppConfig.oauthBaseUrl}/oauth2/auth',
            tokenEndpoint: '${AppConfig.oauthBaseUrl}/oauth2/token',
            endSessionEndpoint:
                '${AppConfig.oauthBaseUrl}/oauth2/sessions/logout',
          ),
        ),
      );

      AppLogger.info('Sign out completed: ${result?.state ?? "success"}');
    } on FlutterAppAuthPlatformException catch (e) {
      AppLogger.warning('Platform error during sign out: ${e.code} - ${e.message}');
      // Don't throw - sign out should always succeed locally
    } catch (e) {
      AppLogger.warning('Error during sign out: $e');
      // Don't throw - sign out should always succeed locally
    }
  }
}

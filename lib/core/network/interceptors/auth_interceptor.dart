import 'package:dio/dio.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/constants/api_constants.dart';
import 'package:iqra_wave/core/di/injection_container.dart';
import 'package:iqra_wave/core/services/token_service.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/domain/usecases/get_access_token.dart';

/// Auth interceptor for Quran.Foundation OAuth2
/// Automatically handles token injection and refresh
class AuthInterceptor extends Interceptor {
  AuthInterceptor()
      : _tokenService = getIt<TokenService>(),
        _getAccessToken = getIt<GetAccessToken>();

  final TokenService _tokenService;
  final GetAccessToken _getAccessToken;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip OAuth2 token endpoint to prevent infinite loop
    if (options.path.contains(ApiConstants.oauth2Token)) {
      AppLogger.debug('Skipping auth interceptor for OAuth endpoint');
      return handler.next(options);
    }

    // Skip legacy login/register endpoints
    if (options.path.contains(ApiConstants.login) ||
        options.path.contains(ApiConstants.register)) {
      return handler.next(options);
    }

    try {
      // Check if token is valid
      final hasValidToken = await _tokenService.hasValidToken();

      if (!hasValidToken && !_isRefreshing) {
        // Token is expired or missing, get a new one
        _isRefreshing = true;
        AppLogger.info('Token expired or missing, requesting new token');

        final result = await _getAccessToken(NoParams());

        result.fold(
          (failure) {
            _isRefreshing = false;
            AppLogger.error('Failed to get access token: ${failure.message}');
            // Continue without token - let the API handle the 401
          },
          (token) {
            _isRefreshing = false;
            AppLogger.info('New token obtained successfully');
          },
        );
      }

      // Get token and client ID
      final token = await _tokenService.getAccessToken();
      final clientId = await _tokenService.getClientId();

      // Add Quran.Foundation specific headers
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.xAuthToken] = token;
        AppLogger.debug('Added x-auth-token header');
      }

      if (clientId != null && clientId.isNotEmpty) {
        options.headers[ApiConstants.xClientId] = clientId;
        AppLogger.debug('Added x-client-id header: $clientId');
      } else {
        // Fallback to config client ID
        options.headers[ApiConstants.xClientId] = AppConfig.oauthClientId;
        AppLogger.debug('Added x-client-id header from config');
      }

      return handler.next(options);
    } catch (e) {
      AppLogger.error('Error in auth interceptor', e);
      _isRefreshing = false;
      return handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - token might be expired
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      try {
        _isRefreshing = true;
        AppLogger.info('Received 401, attempting to refresh token');

        final result = await _getAccessToken(NoParams());

        await result.fold(
          (failure) async {
            _isRefreshing = false;
            AppLogger.error('Token refresh failed: ${failure.message}');
            return handler.next(err);
          },
          (token) async {
            _isRefreshing = false;
            AppLogger.info('Token refreshed, retrying request');

            // Retry the original request with new token
            final requestOptions = err.requestOptions;
            requestOptions.headers[ApiConstants.xAuthToken] = token.accessToken;
            requestOptions.headers[ApiConstants.xClientId] =
                AppConfig.oauthClientId;

            try {
              final response = await Dio().fetch(requestOptions);
              return handler.resolve(response);
            } catch (e) {
              AppLogger.error('Retry request failed', e);
              return handler.next(err);
            }
          },
        );
      } catch (e) {
        _isRefreshing = false;
        AppLogger.error('Error handling 401 response', e);
        return handler.next(err);
      }
    } else {
      return handler.next(err);
    }
  }
}

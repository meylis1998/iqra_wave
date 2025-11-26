import 'package:dio/dio.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/constants/api_constants.dart';
import 'package:iqra_wave/core/di/injection_container.dart';
import 'package:iqra_wave/core/services/token_refresh_manager.dart';
import 'package:iqra_wave/core/services/token_service.dart';
import 'package:iqra_wave/core/utils/logger.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor()
    : _tokenService = getIt<TokenService>(),
      _tokenRefreshManager = getIt<TokenRefreshManager>();

  final TokenService _tokenService;
  final TokenRefreshManager _tokenRefreshManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkipAuth(options)) {
      return handler.next(options);
    }

    try {
      final isExpired = await _tokenService.isTokenExpired();

      if (isExpired) {
        final result = await _tokenRefreshManager.refreshToken();

        result.fold(
          (failure) {
            AppLogger.error('Token refresh failed: ${failure.message}');
          },
          (token) {
            // Token refreshed successfully
          },
        );
      }

      await _addAuthHeaders(options);

      return handler.next(options);
    } catch (e, stackTrace) {
      AppLogger.error('Error in auth interceptor', e, stackTrace);
      return handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final result = await _tokenRefreshManager.refreshToken();

        return await result.fold(
          (failure) async {
            AppLogger.error('Token refresh failed: ${failure.message}');

            await _tokenService.clearTokens();

            return handler.next(err);
          },
          (token) async {
            return _retryRequest(err, handler, token.accessToken);
          },
        );
      } catch (e, stackTrace) {
        AppLogger.error('Error handling 401 response', e, stackTrace);
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldSkipAuth(RequestOptions options) {
    if (options.path.contains(ApiConstants.oauth2Token)) {
      return true;
    }

    return false;
  }

  Future<void> _addAuthHeaders(RequestOptions options) async {
    final token = await _tokenService.getAccessToken();
    final clientId = await _tokenService.getClientId();

    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.xAuthToken] = token;
    }

    if (clientId != null && clientId.isNotEmpty) {
      options.headers[ApiConstants.xClientId] = clientId;
    } else {
      options.headers[ApiConstants.xClientId] = AppConfig.oauthClientId;
    }
  }

  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
    String accessToken,
  ) async {
    final options = err.requestOptions;

    options.headers[ApiConstants.xAuthToken] = accessToken;
    final clientId = await _tokenService.getClientId();
    options.headers[ApiConstants.xClientId] =
        clientId ?? AppConfig.oauthClientId;

    try {
      final response = await Dio().fetch(options);
      return handler.resolve(response);
    } catch (e, stackTrace) {
      AppLogger.error('Retry request failed', e, stackTrace);
      return handler.next(err);
    }
  }
}

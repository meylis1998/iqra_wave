import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/constants/api_constants.dart';
import 'package:iqra_wave/core/error/exceptions.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/data/models/token_response_model.dart';

/// Abstract contract for auth remote data source
abstract class AuthRemoteDataSource {
  /// Request access token using client credentials grant
  Future<TokenResponseModel> getAccessToken();
}

/// Implementation of [AuthRemoteDataSource] using Dio
/// Handles OAuth2 client_credentials flow with Quran.Foundation API
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<TokenResponseModel> getAccessToken() async {
    try {
      AppLogger.info('Requesting OAuth2 access token from ${AppConfig.oauthBaseUrl}');

      // Create a separate Dio instance for OAuth requests to avoid interceptor loops
      final oauthDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.oauthBaseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          sendTimeout: ApiConstants.sendTimeout,
          headers: {
            ApiConstants.contentType: 'application/x-www-form-urlencoded',
            ApiConstants.accept: ApiConstants.applicationJson,
          },
        ),
      );

      // Prepare OAuth2 request body
      final requestData = {
        'grant_type': ApiConstants.grantTypeClientCredentials,
        'client_id': AppConfig.oauthClientId,
        'client_secret': AppConfig.oauthClientSecret,
      };

      AppLogger.debug('OAuth2 request - client_id: ${AppConfig.oauthClientId}');

      final response = await oauthDio.post<Map<String, dynamic>>(
        ApiConstants.oauth2Token,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.info('Access token received successfully');

        // Add issued timestamp
        final tokenData = {
          ...response.data!,
          'issuedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        };

        return TokenResponseModel.fromJson(tokenData);
      } else {
        AppLogger.error('Unexpected response: ${response.statusCode}');
        throw OAuth2Exception(
          'Failed to get access token: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.error(
        'OAuth2 request failed',
        e,
        e.stackTrace,
      );

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        AppLogger.error('OAuth2 error response: $errorData');

        switch (statusCode) {
          case 400:
            throw OAuth2Exception(
              'Invalid OAuth2 request: ${errorData ?? 'Bad request'}',
            );
          case 401:
            throw AuthenticationException(
              'Invalid client credentials',
            );
          case 403:
            throw UnauthorizedException(
              'Access forbidden',
            );
          case 404:
            throw NotFoundException(
              'OAuth2 endpoint not found',
            );
          case int statusCode when statusCode >= 500:
            throw ServerException(
              'OAuth2 server error: $statusCode',
            );
          default:
            throw OAuth2Exception(
              'OAuth2 request failed: $statusCode',
            );
        }
      } else {
        // Network error
        throw NetworkException(
          'Network error: ${e.message}',
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error during OAuth2 request', e);
      throw OAuth2Exception('Unexpected error: $e');
    }
  }
}

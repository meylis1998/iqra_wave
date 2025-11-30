import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/constants/api_constants.dart';
import 'package:iqra_wave/core/error/exceptions.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/data/models/token_response_model.dart';
import 'package:iqra_wave/features/auth/data/models/user_info_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenResponseModel> getAccessToken();

  Future<UserInfoModel> getUserInfo(String accessToken);

  Future<void> logout(String? idTokenHint);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<TokenResponseModel> getAccessToken() async {
    try {
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

      final credentials =
          '${AppConfig.oauthClientId}:${AppConfig.oauthClientSecret}';
      final basicAuth = 'Basic ${base64.encode(utf8.encode(credentials))}';

      final requestData = {
        'grant_type': ApiConstants.grantTypeClientCredentials,
        'scope': ApiConstants.scopeContent,
      };

      final response = await oauthDio.post<Map<String, dynamic>>(
        ApiConstants.oauth2Token,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            ApiConstants.authorization: basicAuth,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final tokenData = {
          ...response.data!,
          'issuedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        };

        return TokenResponseModel.fromJson(tokenData);
      } else {
        throw OAuth2Exception(
          'Failed to get access token: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

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
          case final int statusCode when statusCode >= 500:
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
      throw OAuth2Exception('Unexpected error: $e');
    }
  }

  @override
  Future<UserInfoModel> getUserInfo(String accessToken) async {
    try {
      AppLogger.info('Getting user info with access token: ${accessToken.substring(0, 20)}...');
      AppLogger.info('OAuth Base URL: ${AppConfig.oauthBaseUrl}');
      AppLogger.info('Userinfo endpoint: ${ApiConstants.oauth2Userinfo}');

      final oauthDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.oauthBaseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          headers: {
            ApiConstants.accept: ApiConstants.applicationJson,
            ApiConstants.authorization: '${ApiConstants.bearer} $accessToken',
          },
        ),
      );

      AppLogger.info('Making request to: ${AppConfig.oauthBaseUrl}${ApiConstants.oauth2Userinfo}');

      final response = await oauthDio.get<Map<String, dynamic>>(
        ApiConstants.oauth2Userinfo,
      );

      AppLogger.info('UserInfo Response Status: ${response.statusCode}');
      AppLogger.info('UserInfo Response Data: ${response.data}');
      AppLogger.info('UserInfo Response Headers: ${response.headers}');
      AppLogger.info('UserInfo Full Response: ${response.toString()}');

      if (response.statusCode == 200 && response.data != null) {
        AppLogger.info('Parsing UserInfo from JSON: ${response.data}');
        final userInfo = UserInfoModel.fromJson(response.data!);
        AppLogger.info('Parsed UserInfo: email=${userInfo.email}, firstName=${userInfo.firstName}, lastName=${userInfo.lastName}');
        return userInfo;
      } else {
        AppLogger.error('Failed to get user info - Status: ${response.statusCode}, Data: ${response.data}');
        throw OAuth2Exception(
          'Failed to get user info: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException in getUserInfo: ${e.toString()}');
      AppLogger.error('DioException type: ${e.type}');
      AppLogger.error('DioException message: ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        AppLogger.error('Error Response Status: $statusCode');
        AppLogger.error('Error Response Data: ${e.response!.data}');
        AppLogger.error('Error Response Headers: ${e.response!.headers}');

        switch (statusCode) {
          case 401:
            throw AuthenticationException(
              'Invalid or expired access token',
            );
          case 403:
            throw UnauthorizedException(
              'Access forbidden',
            );
          case 404:
            throw NotFoundException(
              'Userinfo endpoint not found',
            );
          case final int statusCode when statusCode >= 500:
            throw ServerException(
              'Userinfo server error: $statusCode',
            );
          default:
            throw OAuth2Exception(
              'Userinfo request failed: $statusCode',
            );
        }
      } else {
        AppLogger.error('Network error - no response received');
        throw NetworkException(
          'Network error: ${e.message}',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getUserInfo: $e');
      AppLogger.error('Stack trace: $stackTrace');
      throw OAuth2Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> logout(String? idTokenHint) async {
    final oauthDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.oauthBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        followRedirects: false,
        validateStatus: (status) {
          return status != null && (status < 400 || status == 302);
        },
      ),
    );

    final queryParams = <String, dynamic>{};
    if (idTokenHint != null && idTokenHint.isNotEmpty) {
      queryParams['id_token_hint'] = idTokenHint;
    }

    await oauthDio.get(
      ApiConstants.oauth2Logout,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }
}

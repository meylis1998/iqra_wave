import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/constants/api_constants.dart';
import 'package:iqra_wave/core/error/exceptions.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/data/models/token_response_model.dart';
import 'package:iqra_wave/features/auth/data/models/user_info_model.dart';

/// Abstract contract for auth remote data source
abstract class AuthRemoteDataSource {
  /// Request access token using client credentials grant
  Future<TokenResponseModel> getAccessToken();

  /// Get user information from OpenID Connect userinfo endpoint
  /// Requires a valid access token
  Future<UserInfoModel> getUserInfo(String accessToken);

  /// Logout user by calling the OpenID Connect logout endpoint
  Future<void> logout(String? idTokenHint);
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

      // Using Basic Auth (client_secret_basic) as per OAuth2 RFC 6749
      final credentials = '${AppConfig.oauthClientId}:${AppConfig.oauthClientSecret}';
      final basicAuth = 'Basic ${base64.encode(utf8.encode(credentials))}';

      // Prepare OAuth2 request body
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
        // Add issued timestamp
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
      // Create a separate Dio instance for OAuth requests
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

      final response = await oauthDio.get<Map<String, dynamic>>(
        ApiConstants.oauth2Userinfo,
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserInfoModel.fromJson(response.data!);
      } else {
        throw OAuth2Exception(
          'Failed to get user info: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

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
        throw NetworkException(
          'Network error: ${e.message}',
        );
      }
    } catch (e) {
      throw OAuth2Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> logout(String? idTokenHint) async {
    try {
      // Create a separate Dio instance for OAuth requests
      final oauthDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.oauthBaseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          followRedirects: false,
          validateStatus: (status) {
            // Accept 302 redirects as success
            return status != null && (status < 400 || status == 302);
          },
        ),
      );

      final queryParams = <String, dynamic>{};
      if (idTokenHint != null && idTokenHint.isNotEmpty) {
        queryParams['id_token_hint'] = idTokenHint;
      }

      final response = await oauthDio.get(
        ApiConstants.oauth2Logout,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
    } on DioException catch (e) {
      // Don't throw error on logout - just log it
      // The user should still be logged out locally
    } catch (e) {
      // Don't throw - continue with local logout
    }
  }
}

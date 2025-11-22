import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:iqra_wave/core/constants/api_constants.dart';
import 'package:iqra_wave/core/constants/storage_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains(ApiConstants.login) ||
        options.path.contains(ApiConstants.register)) {
      return handler.next(options);
    }

    final token = await _secureStorage.read(
      key: StorageConstants.secureAuthToken,
    );

    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    }

    return handler.next(options);
  }
}

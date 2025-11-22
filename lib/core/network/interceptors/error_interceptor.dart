import 'package:dio/dio.dart';

import 'package:iqra_wave/core/error/exceptions.dart';
import 'package:iqra_wave/core/utils/logger.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('API Error', err, err.stackTrace);

    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = NetworkException('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        exception = _handleStatusCode(err.response?.statusCode);

      case DioExceptionType.cancel:
        exception = ServerException('Request cancelled');

      case DioExceptionType.connectionError:
        exception = NetworkException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        exception = ServerException(
          'An unexpected error occurred: ${err.message}',
        );
    }

    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
      ),
    );
  }

  Exception _handleStatusCode(int? statusCode) {
    return switch (statusCode) {
      400 => ValidationException('Bad request'),
      401 => AuthenticationException('Unauthorized. Please login again.'),
      403 => UnauthorizedException('Access forbidden'),
      404 => NotFoundException(),
      500 ||
      502 ||
      503 => ServerException('Server error. Please try again later.'),
      _ => ServerException('Server error: $statusCode'),
    };
  }
}

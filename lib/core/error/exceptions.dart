class ServerException implements Exception {

  ServerException([this.message = 'Server error occurred']);
  final String message;

  @override
  String toString() => message;
}

class CacheException implements Exception {

  CacheException([this.message = 'Cache error occurred']);
  final String message;

  @override
  String toString() => message;
}

class NetworkException implements Exception {

  NetworkException([this.message = 'No internet connection']);
  final String message;

  @override
  String toString() => message;
}

class ValidationException implements Exception {

  ValidationException([this.message = 'Validation error']);
  final String message;

  @override
  String toString() => message;
}

class AuthenticationException implements Exception {

  AuthenticationException([this.message = 'Authentication failed']);
  final String message;

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {

  UnauthorizedException([this.message = 'Unauthorized access']);
  final String message;

  @override
  String toString() => message;
}

class NotFoundException implements Exception {

  NotFoundException([this.message = 'Resource not found']);
  final String message;

  @override
  String toString() => message;
}

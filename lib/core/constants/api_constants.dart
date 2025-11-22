class ApiConstants {
  static const String devBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String stagingBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String prodBaseUrl = 'https://jsonplaceholder.typicode.com';

  static const String posts = '/posts';
  static const String users = '/users';
  static const String comments = '/comments';
  static const String login = '/login';
  static const String register = '/register';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}

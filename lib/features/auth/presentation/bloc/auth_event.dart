import 'package:equatable/equatable.dart';

/// Base class for all auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize authentication on app startup
/// Checks if valid token exists or requests a new one
class AuthInitialize extends AuthEvent {
  const AuthInitialize();
}

/// Event to manually refresh the access token
class AuthRefreshToken extends AuthEvent {
  const AuthRefreshToken();
}

/// Event to clear all auth data (logout)
class AuthLogout extends AuthEvent {
  const AuthLogout({this.idTokenHint});

  final String? idTokenHint;

  @override
  List<Object?> get props => [idTokenHint];
}

/// Event to check current auth status
class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

/// Event to get user information from OpenID Connect userinfo endpoint
class AuthGetUserInfo extends AuthEvent {
  const AuthGetUserInfo();
}

/// Event to explicitly request authentication (get new token)
/// This should be triggered by user action (e.g., login button)
class AuthRequestLogin extends AuthEvent {
  const AuthRequestLogin();
}

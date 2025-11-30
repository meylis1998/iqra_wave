import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitialize extends AuthEvent {
  const AuthInitialize();
}

class AuthRefreshToken extends AuthEvent {
  const AuthRefreshToken();
}

class AuthLogout extends AuthEvent {
  const AuthLogout({this.idTokenHint});

  final String? idTokenHint;

  @override
  List<Object?> get props => [idTokenHint];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthGetUserInfo extends AuthEvent {
  const AuthGetUserInfo();
}

class AuthRequestLogin extends AuthEvent {
  const AuthRequestLogin();
}

// User Authentication Events (Authorization Code + PKCE)

class AuthSignInWithBrowser extends AuthEvent {
  const AuthSignInWithBrowser();
}

class AuthUserSignOut extends AuthEvent {
  const AuthUserSignOut({this.idToken});

  final String? idToken;

  @override
  List<Object?> get props => [idToken];
}

class AuthRefreshUserToken extends AuthEvent {
  const AuthRefreshUserToken(this.refreshToken);

  final String refreshToken;

  @override
  List<Object?> get props => [refreshToken];
}

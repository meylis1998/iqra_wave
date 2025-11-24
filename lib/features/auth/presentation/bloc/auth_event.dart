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

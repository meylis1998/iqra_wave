import 'package:equatable/equatable.dart';
import 'package:iqra_wave/features/auth/domain/entities/auth_mode.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.token, {this.authMode = AuthMode.clientCredentials});

  final TokenEntity token;
  final AuthMode authMode;

  @override
  List<Object?> get props => [token, authMode];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthRefreshing extends AuthState {
  const AuthRefreshing();
}

class AuthUserInfoLoaded extends AuthState {
  const AuthUserInfoLoaded(this.userInfo, this.token);

  final UserInfoEntity userInfo;
  final TokenEntity token;

  @override
  List<Object?> get props => [userInfo, token];
}

class AuthUserInfoLoading extends AuthState {
  const AuthUserInfoLoading();
}

// User Authentication States (Authorization Code + PKCE)

class AuthSigningInWithBrowser extends AuthState {
  const AuthSigningInWithBrowser();
}

class AuthUserAuthenticated extends AuthState {
  const AuthUserAuthenticated({
    required this.token,
    required this.userInfo,
  });

  final TokenEntity token;
  final UserInfoEntity userInfo;

  @override
  List<Object?> get props => [token, userInfo];
}

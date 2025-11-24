import 'package:equatable/equatable.dart';
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
  const AuthAuthenticated(this.token);

  final TokenEntity token;

  @override
  List<Object?> get props => [token];
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

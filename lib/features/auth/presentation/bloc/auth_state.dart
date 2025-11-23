import 'package:equatable/equatable.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';

/// Base class for all auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth operations
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state while checking or fetching token
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated with valid token
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.token);

  final TokenEntity token;

  @override
  List<Object?> get props => [token];
}

/// State when user is not authenticated (no token or invalid)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// State when an error occurs during auth operations
class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// State when token is being refreshed
class AuthRefreshing extends AuthState {
  const AuthRefreshing();
}

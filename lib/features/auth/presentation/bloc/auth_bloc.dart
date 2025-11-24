import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';
import 'package:iqra_wave/features/auth/domain/usecases/get_access_token.dart';
import 'package:iqra_wave/features/auth/domain/usecases/get_user_info.dart';
import 'package:iqra_wave/features/auth/domain/usecases/logout_user.dart';
import 'package:iqra_wave/features/auth/domain/usecases/refresh_token.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_event.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_state.dart';

/// BLoC for managing authentication state
/// Handles OAuth2 token lifecycle for Quran.Foundation API
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._getAccessToken,
    this._refreshToken,
    this._getUserInfo,
    this._logoutUser,
    this._authRepository,
  ) : super(const AuthInitial()) {
    on<AuthInitialize>(_onInitialize);
    on<AuthRefreshToken>(_onRefreshToken);
    on<AuthLogout>(_onLogout);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthGetUserInfo>(_onGetUserInfo);
    on<AuthRequestLogin>(_onRequestLogin);
  }

  final GetAccessToken _getAccessToken;
  final RefreshToken _refreshToken;
  final GetUserInfo _getUserInfo;
  final LogoutUser _logoutUser;
  final AuthRepository _authRepository;

  // Cache the current token for user info requests
  TokenEntity? _currentToken;

  /// Initialize authentication on app startup
  /// Checks if valid token exists in storage
  /// Does NOT automatically request new token if none exists
  Future<void> _onInitialize(
    AuthInitialize event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Check if valid token already exists
      final hasValidToken = await _authRepository.hasValidToken();

      if (hasValidToken) {
        // Retrieve the stored token without making API call
        final result = await _authRepository.getStoredToken();

        result.fold(
          (failure) {
            // Token exists but couldn't be retrieved - stay unauthenticated
            _currentToken = null;
            emit(const AuthUnauthenticated('Please authenticate'));
          },
          (token) {
            _currentToken = token;
            emit(AuthAuthenticated(token));
          },
        );
      } else {
        // No valid token - user needs to authenticate explicitly
        _currentToken = null;
        emit(const AuthUnauthenticated('Please authenticate'));
      }
    } catch (e) {
      _currentToken = null;
      emit(const AuthUnauthenticated('Authentication required'));
    }
  }

  /// Refresh the access token
  Future<void> _onRefreshToken(
    AuthRefreshToken event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthRefreshing());

    try {
      final result = await _refreshToken(NoParams());

      result.fold(
        (failure) {
          _currentToken = null;
          emit(AuthError(failure.message));
        },
        (token) {
          _currentToken = token;
          emit(AuthAuthenticated(token));
        },
      );
    } catch (e) {
      emit(AuthError('Failed to refresh token: $e'));
    }
  }

  /// Logout - clear all auth data
  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _logoutUser(
        LogoutParams(idTokenHint: event.idTokenHint),
      );

      result.fold(
        (failure) {
          // Still emit unauthenticated even if server call failed
          _currentToken = null;
          emit(const AuthUnauthenticated('Logged out (offline)'));
        },
        (_) {
          _currentToken = null;
          emit(const AuthUnauthenticated('Logged out successfully'));
        },
      );
    } catch (e) {
      _currentToken = null;
      emit(const AuthUnauthenticated('Logged out (error)'));
    }
  }

  /// Check current authentication status
  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final hasValidToken = await _authRepository.hasValidToken();

      if (hasValidToken) {
        // Get fresh token to have the entity
        final result = await _getAccessToken(NoParams());

        result.fold(
          (failure) {
            _currentToken = null;
            emit(AuthUnauthenticated(failure.message));
          },
          (token) {
            _currentToken = token;
            emit(AuthAuthenticated(token));
          },
        );
      } else {
        emit(const AuthUnauthenticated('No valid token'));
      }
    } catch (e) {
      emit(AuthError('Failed to check auth status: $e'));
    }
  }

  /// Get user information from OpenID Connect userinfo endpoint
  Future<void> _onGetUserInfo(
    AuthGetUserInfo event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUserInfoLoading());

    try {
      // Ensure we have a valid token first
      if (_currentToken == null) {
        final tokenResult = await _getAccessToken(NoParams());
        await tokenResult.fold(
          (failure) async {
            emit(AuthError('Failed to authenticate: ${failure.message}'));
            return;
          },
          (token) async {
            _currentToken = token;
          },
        );
      }

      if (_currentToken == null) {
        emit(const AuthError('No valid token available'));
        return;
      }

      // Get user info
      final result = await _getUserInfo(NoParams());

      result.fold(
        (failure) {
          emit(AuthError(failure.message));
        },
        (userInfo) {
          emit(AuthUserInfoLoaded(userInfo, _currentToken!));
        },
      );
    } catch (e) {
      emit(AuthError('Failed to get user info: $e'));
    }
  }

  /// Request login - explicitly get a new access token
  /// This should be triggered by user action (e.g., login button)
  Future<void> _onRequestLogin(
    AuthRequestLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await _getAccessToken(NoParams());

      result.fold(
        (failure) {
          _currentToken = null;
          emit(AuthError(failure.message));
        },
        (token) {
          _currentToken = token;
          emit(AuthAuthenticated(token));
        },
      );
    } catch (e) {
      _currentToken = null;
      emit(AuthError('Failed to authenticate: $e'));
    }
  }
}

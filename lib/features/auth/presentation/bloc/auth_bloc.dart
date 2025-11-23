import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/core/utils/logger.dart';
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
  }

  final GetAccessToken _getAccessToken;
  final RefreshToken _refreshToken;
  final GetUserInfo _getUserInfo;
  final LogoutUser _logoutUser;
  final AuthRepository _authRepository;

  // Cache the current token for user info requests
  TokenEntity? _currentToken;

  /// Initialize authentication on app startup
  /// Checks if valid token exists, otherwise requests a new one
  Future<void> _onInitialize(
    AuthInitialize event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    AppLogger.info('Initializing authentication');

    try {
      // Check if valid token already exists
      final hasValidToken = await _authRepository.hasValidToken();

      if (hasValidToken) {
        AppLogger.info('Valid token exists, user is authenticated');
        // We don't have the token entity here, so we need to get it
        // For now, we'll request a fresh token to ensure we have the entity
        final result = await _getAccessToken(NoParams());

        result.fold(
          (failure) {
            AppLogger.error('Failed to get token: ${failure.message}');
            _currentToken = null;
            emit(AuthUnauthenticated(failure.message));
          },
          (token) {
            AppLogger.info('Authentication successful');
            _currentToken = token;
            emit(AuthAuthenticated(token));
          },
        );
      } else {
        AppLogger.info('No valid token, requesting new token');
        final result = await _getAccessToken(NoParams());

        result.fold(
          (failure) {
            AppLogger.error('Failed to get access token: ${failure.message}');
            _currentToken = null;
            emit(AuthError(failure.message));
          },
          (token) {
            AppLogger.info('Access token obtained successfully');
            _currentToken = token;
            emit(AuthAuthenticated(token));
          },
        );
      }
    } catch (e) {
      AppLogger.error('Error during auth initialization', e);
      emit(AuthError('Failed to initialize authentication: $e'));
    }
  }

  /// Refresh the access token
  Future<void> _onRefreshToken(
    AuthRefreshToken event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthRefreshing());
    AppLogger.info('Refreshing access token');

    try {
      final result = await _refreshToken(NoParams());

      result.fold(
        (failure) {
          AppLogger.error('Failed to refresh token: ${failure.message}');
          _currentToken = null;
          emit(AuthError(failure.message));
        },
        (token) {
          AppLogger.info('Token refreshed successfully');
          _currentToken = token;
          emit(AuthAuthenticated(token));
        },
      );
    } catch (e) {
      AppLogger.error('Error during token refresh', e);
      emit(AuthError('Failed to refresh token: $e'));
    }
  }

  /// Logout - clear all auth data
  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    AppLogger.info('Logging out');

    try {
      final result = await _logoutUser(
        LogoutParams(idTokenHint: event.idTokenHint),
      );

      result.fold(
        (failure) {
          AppLogger.warning('Logout API error: ${failure.message}');
          // Still emit unauthenticated even if server call failed
          _currentToken = null;
          emit(const AuthUnauthenticated('Logged out (offline)'));
        },
        (_) {
          AppLogger.info('Logout successful');
          _currentToken = null;
          emit(const AuthUnauthenticated('Logged out successfully'));
        },
      );
    } catch (e) {
      AppLogger.error('Error during logout', e);
      _currentToken = null;
      emit(const AuthUnauthenticated('Logged out (error)'));
    }
  }

  /// Check current authentication status
  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Checking auth status');

    try {
      final hasValidToken = await _authRepository.hasValidToken();

      if (hasValidToken) {
        AppLogger.info('Valid token exists');
        // Get fresh token to have the entity
        final result = await _getAccessToken(NoParams());

        result.fold(
          (failure) {
            AppLogger.error('Failed to get token: ${failure.message}');
            _currentToken = null;
            emit(AuthUnauthenticated(failure.message));
          },
          (token) {
            _currentToken = token;
            emit(AuthAuthenticated(token));
          },
        );
      } else {
        AppLogger.info('No valid token');
        emit(const AuthUnauthenticated('No valid token'));
      }
    } catch (e) {
      AppLogger.error('Error checking auth status', e);
      emit(AuthError('Failed to check auth status: $e'));
    }
  }

  /// Get user information from OpenID Connect userinfo endpoint
  Future<void> _onGetUserInfo(
    AuthGetUserInfo event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUserInfoLoading());
    AppLogger.info('Getting user info');

    try {
      // Ensure we have a valid token first
      if (_currentToken == null) {
        final tokenResult = await _getAccessToken(NoParams());
        await tokenResult.fold(
          (failure) async {
            AppLogger.error('Failed to get token: ${failure.message}');
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
          AppLogger.error('Failed to get user info: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (userInfo) {
          AppLogger.info('User info obtained: ${userInfo.email}');
          emit(AuthUserInfoLoaded(userInfo, _currentToken!));
        },
      );
    } catch (e) {
      AppLogger.error('Error getting user info', e);
      emit(AuthError('Failed to get user info: $e'));
    }
  }
}

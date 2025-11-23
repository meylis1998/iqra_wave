import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';
import 'package:iqra_wave/features/auth/domain/usecases/get_access_token.dart';
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
    this._authRepository,
  ) : super(const AuthInitial()) {
    on<AuthInitialize>(_onInitialize);
    on<AuthRefreshToken>(_onRefreshToken);
    on<AuthLogout>(_onLogout);
    on<AuthCheckStatus>(_onCheckStatus);
  }

  final GetAccessToken _getAccessToken;
  final RefreshToken _refreshToken;
  final AuthRepository _authRepository;

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
            emit(AuthUnauthenticated(failure.message));
          },
          (token) {
            AppLogger.info('Authentication successful');
            emit(AuthAuthenticated(token));
          },
        );
      } else {
        AppLogger.info('No valid token, requesting new token');
        final result = await _getAccessToken(NoParams());

        result.fold(
          (failure) {
            AppLogger.error('Failed to get access token: ${failure.message}');
            emit(AuthError(failure.message));
          },
          (token) {
            AppLogger.info('Access token obtained successfully');
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
          emit(AuthError(failure.message));
        },
        (token) {
          AppLogger.info('Token refreshed successfully');
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
      await _authRepository.clearAuthData();
      AppLogger.info('Logout successful');
      emit(const AuthUnauthenticated('Logged out successfully'));
    } catch (e) {
      AppLogger.error('Error during logout', e);
      emit(AuthError('Failed to logout: $e'));
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
            emit(AuthUnauthenticated(failure.message));
          },
          (token) {
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
}

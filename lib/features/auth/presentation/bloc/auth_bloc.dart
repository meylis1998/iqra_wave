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

  TokenEntity? _currentToken;

  Future<void> _onInitialize(
    AuthInitialize event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final hasValidToken = await _authRepository.hasValidToken();

      if (hasValidToken) {
        final result = await _authRepository.getStoredToken();

        result.fold(
          (failure) {
            _currentToken = null;
            emit(const AuthUnauthenticated('Please authenticate'));
          },
          (token) {
            _currentToken = token;
            emit(AuthAuthenticated(token));
          },
        );
      } else {
        _currentToken = null;
        emit(const AuthUnauthenticated('Please authenticate'));
      }
    } catch (e) {
      _currentToken = null;
      emit(const AuthUnauthenticated('Authentication required'));
    }
  }

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

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final hasValidToken = await _authRepository.hasValidToken();

      if (hasValidToken) {
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

  Future<void> _onGetUserInfo(
    AuthGetUserInfo event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUserInfoLoading());

    try {
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

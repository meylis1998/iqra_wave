import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/exceptions.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/services/token_service.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository]
/// Coordinates between remote data source and local token storage
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenService,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final TokenService _tokenService;

  @override
  Future<Either<Failure, TokenEntity>> getAccessToken() async {
    try {
      AppLogger.info('Getting access token');

      // Request new token from OAuth2 server
      final tokenModel = await _remoteDataSource.getAccessToken();

      // Store the token securely
      await _tokenService.storeToken(tokenModel);

      // Convert model to entity
      final entity = TokenEntity(
        accessToken: tokenModel.accessToken,
        tokenType: tokenModel.tokenType,
        expiresIn: tokenModel.expiresIn,
        issuedAt: tokenModel.issuedAt,
      );

      AppLogger.info('Access token obtained and stored successfully');
      return Right(entity);
    } on OAuth2Exception catch (e) {
      AppLogger.error('OAuth2 error: ${e.message}');
      return Left(OAuth2Failure(e.message));
    } on AuthenticationException catch (e) {
      AppLogger.error('Authentication error: ${e.message}');
      return Left(AuthenticationFailure(e.message));
    } on UnauthorizedException catch (e) {
      AppLogger.error('Unauthorized error: ${e.message}');
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      AppLogger.error('Server error: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error getting access token', e);
      return Left(UnexpectedFailure('Failed to get access token: $e'));
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> refreshToken() async {
    // For client_credentials grant, refreshing is the same as getting a new token
    // There's no refresh token in this flow
    AppLogger.info('Refreshing token (getting new token)');
    return getAccessToken();
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      return await _tokenService.hasValidToken();
    } catch (e) {
      AppLogger.error('Error checking valid token', e);
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      AppLogger.info('Clearing auth data');
      await _tokenService.clearTokens();
      AppLogger.info('Auth data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing auth data', e);
      rethrow;
    }
  }

  @override
  Future<Either<Failure, UserInfoEntity>> getUserInfo() async {
    try {
      AppLogger.info('Getting user info');

      // Get current access token
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        AppLogger.error('No access token available');
        return const Left(AuthenticationFailure('No access token available'));
      }

      // Request user info from server
      final userInfoModel = await _remoteDataSource.getUserInfo(accessToken);

      AppLogger.info('User info obtained successfully');
      return Right(userInfoModel.toEntity());
    } on OAuth2Exception catch (e) {
      AppLogger.error('OAuth2 error: ${e.message}');
      return Left(OAuth2Failure(e.message));
    } on AuthenticationException catch (e) {
      AppLogger.error('Authentication error: ${e.message}');
      return Left(AuthenticationFailure(e.message));
    } on UnauthorizedException catch (e) {
      AppLogger.error('Unauthorized error: ${e.message}');
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      AppLogger.error('Server error: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error getting user info', e);
      return Left(UnexpectedFailure('Failed to get user info: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout({String? idTokenHint}) async {
    try {
      AppLogger.info('Logging out user');

      // Call logout endpoint on server
      await _remoteDataSource.logout(idTokenHint);

      // Clear local auth data
      await clearAuthData();

      AppLogger.info('Logout successful');
      return const Right(unit);
    } on NetworkException catch (e) {
      AppLogger.error('Network error during logout: ${e.message}');
      // Still clear local data even if network call fails
      await clearAuthData();
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Error during logout', e);
      // Still clear local data
      await clearAuthData();
      return Left(UnexpectedFailure('Logout error: $e'));
    }
  }
}

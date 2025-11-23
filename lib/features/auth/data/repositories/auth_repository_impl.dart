import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/exceptions.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/services/token_service.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
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
}

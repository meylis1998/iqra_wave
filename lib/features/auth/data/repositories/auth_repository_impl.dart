import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/exceptions.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/services/token_service.dart';
import 'package:iqra_wave/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

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
      final tokenModel = await _remoteDataSource.getAccessToken();

      await _tokenService.storeToken(tokenModel);

      final entity = TokenEntity(
        accessToken: tokenModel.accessToken,
        tokenType: tokenModel.tokenType,
        expiresIn: tokenModel.expiresIn,
        issuedAt: tokenModel.issuedAt,
      );

      return Right(entity);
    } on OAuth2Exception catch (e) {
      return Left(OAuth2Failure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get access token: $e'));
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> refreshToken() async {
    return getAccessToken();
  }

  @override
  Future<bool> hasValidToken() async {
    return _tokenService.hasValidToken();
  }

  @override
  Future<Either<Failure, TokenEntity>> getStoredToken() async {
    try {
      final accessToken = await _tokenService.getAccessToken();
      final expiry = await _tokenService.getTokenExpiry();

      if (accessToken == null || accessToken.isEmpty || expiry == null) {
        return const Left(AuthenticationFailure('No stored token available'));
      }

      final isExpired = await _tokenService.isTokenExpired();
      if (isExpired) {
        return const Left(TokenExpiredFailure('Stored token has expired'));
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiresIn = expiry - now;
      final issuedAt = expiry - expiresIn;

      final entity = TokenEntity(
        accessToken: accessToken,
        tokenType: 'Bearer',
        expiresIn: expiresIn,
        issuedAt: issuedAt,
      );

      return Right(entity);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get stored token: $e'));
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _tokenService.clearTokens();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, UserInfoEntity>> getUserInfo() async {
    try {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return const Left(AuthenticationFailure('No access token available'));
      }

      final userInfoModel = await _remoteDataSource.getUserInfo(accessToken);

      return Right(userInfoModel.toEntity());
    } on OAuth2Exception catch (e) {
      return Left(OAuth2Failure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get user info: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout({String? idTokenHint}) async {
    try {
      await _remoteDataSource.logout(idTokenHint);

      await clearAuthData();

      return const Right(unit);
    } on NetworkException catch (e) {
      await clearAuthData();
      return Left(NetworkFailure(e.message));
    } catch (e) {
      await clearAuthData();
      return Left(UnexpectedFailure('Logout error: $e'));
    }
  }
}

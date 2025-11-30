import 'package:dartz/dartz.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';

abstract class AuthRepository {
  // Client Credentials Flow (for content APIs)
  Future<Either<Failure, TokenEntity>> getAccessToken();

  Future<Either<Failure, TokenEntity>> refreshToken();

  // Authorization Code + PKCE Flow (for user authentication)
  Future<Either<Failure, TokenEntity>> signInWithBrowser();

  Future<Either<Failure, TokenEntity>> refreshUserToken(String refreshToken);

  Future<Either<Failure, Unit>> signOut({String? idToken});

  // Common methods
  Future<bool> hasValidToken();

  Future<Either<Failure, TokenEntity>> getStoredToken();

  Future<Either<Failure, UserInfoEntity>> getUserInfo();

  Future<Either<Failure, Unit>> logout({String? idTokenHint});

  Future<void> clearAuthData();
}

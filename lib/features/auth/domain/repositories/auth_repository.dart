import 'package:dartz/dartz.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, TokenEntity>> getAccessToken();

  Future<Either<Failure, TokenEntity>> refreshToken();

  Future<bool> hasValidToken();

  Future<Either<Failure, TokenEntity>> getStoredToken();

  Future<Either<Failure, UserInfoEntity>> getUserInfo();

  Future<Either<Failure, Unit>> logout({String? idTokenHint});

  Future<void> clearAuthData();
}

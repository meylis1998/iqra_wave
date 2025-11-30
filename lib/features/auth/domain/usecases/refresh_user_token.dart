import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for refreshing user token
class RefreshUserTokenParams extends Equatable {
  const RefreshUserTokenParams(this.refreshToken);

  final String refreshToken;

  @override
  List<Object?> get props => [refreshToken];
}

/// Use case for refreshing user access token using refresh token
///
/// This:
/// 1. Uses the stored refresh token to request a new access token
/// 2. Returns updated access token (and possibly new refresh token)
/// 3. No user interaction required
@lazySingleton
class RefreshUserToken implements UseCase<TokenEntity, RefreshUserTokenParams> {
  RefreshUserToken(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, TokenEntity>> call(
    RefreshUserTokenParams params,
  ) async {
    return _repository.refreshUserToken(params.refreshToken);
  }
}

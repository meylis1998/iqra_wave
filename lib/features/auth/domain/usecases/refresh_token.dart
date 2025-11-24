import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

/// Use case for refreshing an OAuth2 access token
/// For client_credentials grant, this is equivalent to getting a new token
/// as there's no refresh token in this flow
@lazySingleton
class RefreshToken implements UseCase<TokenEntity, NoParams> {
  RefreshToken(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, TokenEntity>> call(NoParams params) async {
    return _repository.refreshToken();
  }
}

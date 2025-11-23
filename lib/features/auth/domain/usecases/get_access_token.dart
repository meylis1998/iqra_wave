import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

/// Use case for obtaining an OAuth2 access token
/// Uses client_credentials grant type to authenticate with Quran.Foundation API
@lazySingleton
class GetAccessToken implements UseCase<TokenEntity, NoParams> {
  GetAccessToken(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, TokenEntity>> call(NoParams params) async {
    return await _repository.getAccessToken();
  }
}

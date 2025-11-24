import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class GetUserInfo implements UseCase<UserInfoEntity, NoParams> {
  GetUserInfo(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserInfoEntity>> call(NoParams params) async {
    return _repository.getUserInfo();
  }
}

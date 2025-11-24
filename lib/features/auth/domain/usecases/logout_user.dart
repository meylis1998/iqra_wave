import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

class LogoutParams extends Equatable {
  const LogoutParams({this.idTokenHint});

  final String? idTokenHint;

  @override
  List<Object?> get props => [idTokenHint];
}

@lazySingleton
class LogoutUser implements UseCase<Unit, LogoutParams> {
  LogoutUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(LogoutParams params) async {
    return _repository.logout(idTokenHint: params.idTokenHint);
  }
}

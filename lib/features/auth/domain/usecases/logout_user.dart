import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for logout operation
class LogoutParams extends Equatable {
  const LogoutParams({this.idTokenHint});

  /// Optional ID token hint for the logout endpoint
  final String? idTokenHint;

  @override
  List<Object?> get props => [idTokenHint];
}

/// Use case for logging out user
/// Calls the OpenID Connect logout endpoint and clears local auth data
@lazySingleton
class LogoutUser implements UseCase<Unit, LogoutParams> {
  LogoutUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(LogoutParams params) async {
    return await _repository.logout(idTokenHint: params.idTokenHint);
  }
}

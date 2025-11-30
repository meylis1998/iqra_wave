import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for sign out
class SignOutParams extends Equatable {
  const SignOutParams({this.idToken});

  final String? idToken;

  @override
  List<Object?> get props => [idToken];
}

/// Use case for signing out a user from browser-based OAuth2 session
///
/// This:
/// 1. Calls the OAuth2 logout endpoint to end server session
/// 2. Clears local token storage
/// 3. Returns to unauthenticated state
@lazySingleton
class SignOutUser implements UseCase<Unit, SignOutParams> {
  SignOutUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SignOutParams params) async {
    return _repository.signOut(idToken: params.idToken);
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing in a user via browser-based OAuth2 flow
///
/// This initiates the Authorization Code + PKCE flow:
/// 1. Opens browser for user to authenticate
/// 2. User grants permissions
/// 3. Exchanges authorization code for access + refresh tokens
/// 4. Returns tokens for secure storage
@lazySingleton
class SignInWithBrowser implements UseCase<TokenEntity, NoParams> {
  SignInWithBrowser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, TokenEntity>> call(NoParams params) async {
    return _repository.signInWithBrowser();
  }
}

import 'package:dartz/dartz.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';

/// Repository interface for authentication operations
/// Defines the contract for obtaining and managing OAuth2 tokens
abstract class AuthRepository {
  /// Get a new access token using client credentials grant
  /// Returns [TokenEntity] on success or [Failure] on error
  Future<Either<Failure, TokenEntity>> getAccessToken();

  /// Refresh the current access token
  /// For client_credentials grant, this is the same as getting a new token
  /// Returns [TokenEntity] on success or [Failure] on error
  Future<Either<Failure, TokenEntity>> refreshToken();

  /// Check if a valid token exists in storage
  /// Returns true if token exists and is not expired
  Future<bool> hasValidToken();

  /// Get user information from OpenID Connect userinfo endpoint
  /// Requires a valid access token
  /// Returns [UserInfoEntity] on success or [Failure] on error
  Future<Either<Failure, UserInfoEntity>> getUserInfo();

  /// Logout user from OAuth2 server and clear local data
  /// Optionally accepts an ID token hint for the logout endpoint
  /// Returns [Unit] on success or [Failure] on error
  Future<Either<Failure, Unit>> logout({String? idTokenHint});

  /// Clear all authentication data
  /// Used for logout or when switching environments
  Future<void> clearAuthData();
}

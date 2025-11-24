import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/constants/storage_constants.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/data/models/token_response_model.dart';

@lazySingleton
class TokenService {
  TokenService(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  static const int _tokenBufferSeconds = 300; // 5 minutes

  /// Store the access token securely
  /// [token] The token response from OAuth2 server
  Future<void> storeToken(TokenResponseModel token) async {
    try {
      // Calculate issued timestamp if not set
      final issuedAt = token.issuedAt == 0
          ? DateTime.now().millisecondsSinceEpoch ~/ 1000
          : token.issuedAt;

      final updatedToken = token.copyWith(issuedAt: issuedAt);

      await _secureStorage.write(
        key: StorageConstants.quranFoundationToken,
        value: updatedToken.accessToken,
      );

      await _secureStorage.write(
        key: StorageConstants.quranFoundationTokenExpiry,
        value: updatedToken.expiryTimestamp.toString(),
      );

      await _secureStorage.write(
        key: StorageConstants.quranFoundationClientId,
        value: AppConfig.oauthClientId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieve the stored access token
  /// Returns null if no token is stored
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(
        key: StorageConstants.quranFoundationToken,
      );
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Get the token expiry timestamp
  /// Returns null if no expiry is stored
  Future<int?> getTokenExpiry() async {
    try {
      final expiryStr = await _secureStorage.read(
        key: StorageConstants.quranFoundationTokenExpiry,
      );
      return expiryStr != null ? int.tryParse(expiryStr) : null;
    } catch (e) {
      return null;
    }
  }

  /// Get the stored client ID
  Future<String?> getClientId() async {
    try {
      return await _secureStorage.read(
        key: StorageConstants.quranFoundationClientId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if the current token is expired
  /// Includes a 5-minute buffer for proactive refresh
  Future<bool> isTokenExpired() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final isExpired = now >= (expiry - _tokenBufferSeconds);

      return isExpired;
    } catch (e) {
      return true;
    }
  }

  /// Check if a valid token exists
  /// Returns true only if token exists and is not expired
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;

    final isExpired = await isTokenExpired();
    return !isExpired;
  }

  /// Clear all stored tokens and client information
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: StorageConstants.quranFoundationToken),
        _secureStorage.delete(key: StorageConstants.quranFoundationTokenExpiry),
        _secureStorage.delete(key: StorageConstants.quranFoundationClientId),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  /// Get the time remaining until token expires (in seconds)
  /// Returns null if no token or already expired
  Future<int?> getTimeUntilExpiry() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return null;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final remaining = expiry - now;

      return remaining > 0 ? remaining : null;
    } catch (e) {
      return null;
    }
  }
}

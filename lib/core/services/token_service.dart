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
  static const int _tokenBufferSeconds = 300;

  Future<void> storeToken(TokenResponseModel token) async {
    try {
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

  Future<String?> getClientId() async {
    try {
      return await _secureStorage.read(
        key: StorageConstants.quranFoundationClientId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> isTokenExpired() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) {
        return true;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final isExpired = now >= (expiry - _tokenBufferSeconds);

      return isExpired;
    } catch (e) {
      AppLogger.error('Error checking token expiry', e);
      return true;
    }
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;

    final isExpired = await isTokenExpired();
    return !isExpired;
  }

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

  Future<int?> getTimeUntilExpiry() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) {
        return null;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final remaining = expiry - now;

      if (remaining > 0) {
        return remaining;
      } else {
        return null;
      }
    } catch (e) {
      AppLogger.error('Error calculating time until expiry', e);
      return null;
    }
  }
}

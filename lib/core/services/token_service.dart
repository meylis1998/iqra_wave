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

      final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(
        updatedToken.expiryTimestamp * 1000,
      );
      final now = DateTime.now();
      final timeUntilExpiry = expiryDateTime.difference(now);

      AppLogger.info(
        'Token stored successfully:\n'
        '  Issued at: ${DateTime.fromMillisecondsSinceEpoch(issuedAt * 1000)}\n'
        '  Expires at: $expiryDateTime\n'
        '  Valid for: ${timeUntilExpiry.inMinutes} minutes (${timeUntilExpiry.inSeconds} seconds)\n'
        '  Token length: ${updatedToken.accessToken.length} characters',
      );

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
        AppLogger.debug('No token expiry found - token is expired');
        return true;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final isExpired = now >= (expiry - _tokenBufferSeconds);

      if (isExpired) {
        final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
        final timeRemaining = expiry - now;

        AppLogger.warning(
          'Token is expired or expiring soon:\n'
          '  Expires at: $expiryDateTime\n'
          '  Time remaining: $timeRemaining seconds\n'
          '  Buffer threshold: $_tokenBufferSeconds seconds',
        );
      } else {
        final timeRemaining = expiry - now - _tokenBufferSeconds;
        AppLogger.debug(
          'Token is still valid. Time until refresh needed: $timeRemaining seconds',
        );
      }

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
        AppLogger.debug('No token expiry - cannot calculate time remaining');
        return null;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final remaining = expiry - now;

      if (remaining > 0) {
        final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
        AppLogger.debug(
          'Token time remaining:\n'
          '  Expires at: $expiryDateTime\n'
          '  Seconds remaining: $remaining\n'
          '  Minutes remaining: ${(remaining / 60).toStringAsFixed(1)}',
        );
        return remaining;
      } else {
        final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
        AppLogger.warning(
          'Token has already expired:\n'
          '  Expired at: $expiryDateTime\n'
          '  Expired ${remaining.abs()} seconds ago',
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error calculating time until expiry', e);
      return null;
    }
  }
}

import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences service
/// Stores app settings and user preferences
@lazySingleton
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  // Preference keys
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyAnalyticsEnabled = 'analytics_enabled';
  static const String _keyLastLoginMethod = 'last_login_method';
  static const String _keySessionCount = 'session_count';

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      return _prefs.getBool(_keyBiometricEnabled) ?? false;
    } catch (e) {
      AppLogger.error('Failed to get biometric enabled preference', e);
      return false;
    }
  }

  /// Enable/disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final success = await _prefs.setBool(_keyBiometricEnabled, enabled);

      if (success) {
        AppLogger.info('Biometric authentication ${enabled ? "enabled" : "disabled"}');
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set biometric enabled preference', e, stackTrace);
      return false;
    }
  }

  /// Get theme mode preference
  Future<String?> getThemeMode() async {
    try {
      return _prefs.getString(_keyThemeMode);
    } catch (e) {
      AppLogger.error('Failed to get theme mode preference', e);
      return null;
    }
  }

  /// Set theme mode preference
  Future<bool> setThemeMode(String mode) async {
    try {
      return await _prefs.setString(_keyThemeMode, mode);
    } catch (e) {
      AppLogger.error('Failed to set theme mode preference', e);
      return false;
    }
  }

  /// Get language preference
  Future<String?> getLanguage() async {
    try {
      return _prefs.getString(_keyLanguage);
    } catch (e) {
      AppLogger.error('Failed to get language preference', e);
      return null;
    }
  }

  /// Set language preference
  Future<bool> setLanguage(String language) async {
    try {
      return await _prefs.setString(_keyLanguage, language);
    } catch (e) {
      AppLogger.error('Failed to set language preference', e);
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      return _prefs.getBool(_keyNotificationsEnabled) ?? true;
    } catch (e) {
      AppLogger.error('Failed to get notifications enabled preference', e);
      return true;
    }
  }

  /// Enable/disable notifications
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      return await _prefs.setBool(_keyNotificationsEnabled, enabled);
    } catch (e) {
      AppLogger.error('Failed to set notifications enabled preference', e);
      return false;
    }
  }

  /// Check if analytics are enabled (user consent)
  Future<bool> areAnalyticsEnabled() async {
    try {
      return _prefs.getBool(_keyAnalyticsEnabled) ?? true;
    } catch (e) {
      AppLogger.error('Failed to get analytics enabled preference', e);
      return true;
    }
  }

  /// Enable/disable analytics (user consent)
  Future<bool> setAnalyticsEnabled(bool enabled) async {
    try {
      return await _prefs.setBool(_keyAnalyticsEnabled, enabled);
    } catch (e) {
      AppLogger.error('Failed to set analytics enabled preference', e);
      return false;
    }
  }

  /// Get last login method
  Future<String?> getLastLoginMethod() async {
    try {
      return _prefs.getString(_keyLastLoginMethod);
    } catch (e) {
      AppLogger.error('Failed to get last login method', e);
      return null;
    }
  }

  /// Set last login method
  Future<bool> setLastLoginMethod(String method) async {
    try {
      return await _prefs.setString(_keyLastLoginMethod, method);
    } catch (e) {
      AppLogger.error('Failed to set last login method', e);
      return false;
    }
  }

  /// Get session count
  Future<int> getSessionCount() async {
    try {
      return _prefs.getInt(_keySessionCount) ?? 0;
    } catch (e) {
      AppLogger.error('Failed to get session count', e);
      return 0;
    }
  }

  /// Increment session count
  Future<bool> incrementSessionCount() async {
    try {
      final count = await getSessionCount();
      return await _prefs.setInt(_keySessionCount, count + 1);
    } catch (e) {
      AppLogger.error('Failed to increment session count', e);
      return false;
    }
  }

  /// Clear all preferences (except analytics consent for GDPR)
  Future<bool> clearAllPreferences() async {
    try {
      // Save analytics consent before clearing
      final analyticsEnabled = await areAnalyticsEnabled();

      // Clear all
      await _prefs.clear();

      // Restore analytics consent
      await setAnalyticsEnabled(analyticsEnabled);

      AppLogger.info('All preferences cleared');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear preferences', e, stackTrace);
      return false;
    }
  }

  /// Get all preferences for debugging
  Map<String, dynamic> getAllPreferences() {
    return {
      'biometric_enabled': _prefs.getBool(_keyBiometricEnabled),
      'theme_mode': _prefs.getString(_keyThemeMode),
      'language': _prefs.getString(_keyLanguage),
      'notifications_enabled': _prefs.getBool(_keyNotificationsEnabled),
      'analytics_enabled': _prefs.getBool(_keyAnalyticsEnabled),
      'last_login_method': _prefs.getString(_keyLastLoginMethod),
      'session_count': _prefs.getInt(_keySessionCount),
    };
  }
}

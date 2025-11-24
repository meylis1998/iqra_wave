import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric authentication service
/// Handles Face ID, Touch ID, and fingerprint authentication
@lazySingleton
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometric authentication is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      final isAvailable = canCheckBiometrics && isDeviceSupported;

      AppLogger.debug(
        'Biometric availability:\n'
        '  Can check: $canCheckBiometrics\n'
        '  Device supported: $isDeviceSupported\n'
        '  Available: $isAvailable',
      );

      return isAvailable;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check biometric availability', e, stackTrace);
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();

      AppLogger.debug(
        'Available biometrics: ${biometrics.map((e) => e.name).join(", ")}',
      );

      return biometrics;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get available biometrics', e, stackTrace);
      return [];
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = true,
  }) async {
    try {
      // Check if biometrics are available first
      final isAvailable = await isBiometricAvailable();

      if (!isAvailable) {
        AppLogger.warning('Biometric authentication not available on device');
        return false;
      }

      AppLogger.info('Starting biometric authentication');

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      if (authenticated) {
        AppLogger.info('Biometric authentication successful');
      } else {
        AppLogger.warning('Biometric authentication failed or cancelled');
      }

      return authenticated;
    } catch (e, stackTrace) {
      AppLogger.error('Biometric authentication error', e, stackTrace);
      return false;
    }
  }

  /// Stop biometric authentication (if in progress)
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
      AppLogger.debug('Biometric authentication stopped');
    } catch (e) {
      AppLogger.error('Failed to stop biometric authentication', e);
    }
  }

  /// Get human-readable name for biometric type
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Get description of available biometrics for UI
  Future<String> getBiometricDescription() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) {
      return 'No biometric authentication available';
    }

    if (biometrics.length == 1) {
      return getBiometricTypeName(biometrics.first);
    }

    final names = biometrics.map(getBiometricTypeName).toList();
    return names.join(' or ');
  }

  /// Check if Face ID is available (iOS)
  Future<bool> isFaceIdAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Check if fingerprint is available
  Future<bool> isFingerprintAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }
}

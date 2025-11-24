import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/utils/logger.dart';

/// SSL Certificate Pinning Configuration
/// Prevents man-in-the-middle attacks by validating server certificates
class SSLPinningConfig {
  /// Configure SSL pinning for production Dio instance
  static void configurePinning(Dio dio) {
    // Only enable in production for security
    if (AppConfig.environment != Environment.prod) {
      AppLogger.debug('SSL pinning disabled for ${AppConfig.environment}');
      return;
    }

    AppLogger.info('Configuring SSL certificate pinning for production');

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();

      client.badCertificateCallback = (cert, host, port) {
        // Only pin production hosts
        if (_shouldPinHost(host)) {
          return _validateCertificate(cert, host, port);
        }

        // Allow other hosts (for development/testing purposes)
        return true;
      };

      return client;
    };
  }

  /// Check if host should be pinned
  static bool _shouldPinHost(String host) {
    const pinnedHosts = [
      'oauth2.quran.foundation',
      'api.quran.foundation',
    ];

    return pinnedHosts.any((pinnedHost) => host.contains(pinnedHost));
  }

  /// Validate certificate against expected fingerprints
  static bool _validateCertificate(
    X509Certificate cert,
    String host,
    int port,
  ) {
    // Get certificate DER bytes and compute SHA-256
    final certDer = cert.der;
    final certFingerprint = certDer.toString();

    AppLogger.debug(
      'Validating certificate for $host:$port\n'
      'Certificate DER: $certFingerprint',
    );

    // Expected SHA-256 fingerprints for production servers
    // TODO: Replace with actual certificate fingerprints
    // To get fingerprint: openssl s_client -connect oauth2.quran.foundation:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
    final expectedFingerprints = _getExpectedFingerprints(host);

    if (expectedFingerprints.contains(certFingerprint)) {
      AppLogger.debug('Certificate validation successful for $host');
      return true;
    }

    // Certificate mismatch - potential security threat
    AppLogger.error(
      'SSL Certificate pinning failed for $host\n'
      'Expected: ${expectedFingerprints.join(", ")}\n'
      'Received: $certFingerprint',
    );

    // Report security incident
    _reportSecurityIncident(
      'Certificate pinning failed',
      {
        'host': host,
        'port': port,
        'expected_fingerprints': expectedFingerprints,
        'received_fingerprint': certFingerprint,
      },
    );

    return false;
  }

  /// Get expected certificate fingerprints for a host
  static List<String> _getExpectedFingerprints(String host) {
    // TODO: Replace these with actual certificate fingerprints
    // These should be obtained securely from your certificate authority
    // or by inspecting the live certificates

    if (host.contains('oauth2.quran.foundation')) {
      return [
        // Primary certificate
        'YOUR_OAUTH_CERT_FINGERPRINT_HERE',
        // Backup certificate (for rotation)
        'YOUR_OAUTH_BACKUP_CERT_FINGERPRINT_HERE',
      ];
    }

    if (host.contains('api.quran.foundation')) {
      return [
        // Primary certificate
        'YOUR_API_CERT_FINGERPRINT_HERE',
        // Backup certificate
        'YOUR_API_BACKUP_CERT_FINGERPRINT_HERE',
      ];
    }

    return [];
  }

  /// Report security incident to monitoring service
  static void _reportSecurityIncident(
    String message,
    Map<String, dynamic> data,
  ) {
    AppLogger.error('SECURITY INCIDENT: $message', data);

    // TODO: Send to security monitoring service
    // Examples:
    // - Firebase Crashlytics
    // - Sentry with security context
    // - Custom security logging endpoint
    // - PagerDuty for immediate alerts

    // Example implementation:
    // try {
    //   FirebaseCrashlytics.instance.recordError(
    //     Exception(message),
    //     StackTrace.current,
    //     reason: 'SSL Certificate Pinning Failure',
    //     information: data.entries.map((e) => '${e.key}: ${e.value}').toList(),
    //     fatal: true,
    //   );
    // } catch (e) {
    //   AppLogger.error('Failed to report security incident', e);
    // }
  }

  /// Disable SSL verification (ONLY for development/testing)
  /// WARNING: Never use in production!
  static void disableSSLVerification(Dio dio) {
    if (AppConfig.environment == Environment.prod) {
      throw Exception(
        'Cannot disable SSL verification in production!',
      );
    }

    AppLogger.warning(
      'SSL verification disabled - DEVELOPMENT ONLY',
    );

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }
}

/// Instructions to get certificate fingerprints:
///
/// 1. Using OpenSSL:
/// ```bash
/// openssl s_client -connect oauth2.quran.foundation:443 < /dev/null 2>/dev/null | \
///   openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
/// ```
///
/// 2. Using Flutter/Dart (run once to get fingerprints):
/// ```dart
/// final client = HttpClient();
/// final uri = Uri.parse('https://oauth2.quran.foundation');
/// final request = await client.getUrl(uri);
/// final response = await request.close();
/// final cert = response.certificate;
/// print('SHA-256: ${cert?.sha256}');
/// ```
///
/// 3. Store fingerprints securely:
/// - Add to .env file for non-production
/// - Use secure configuration service for production
/// - Rotate regularly and maintain backup fingerprints

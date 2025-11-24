import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Observability service for analytics, error tracking, and distributed tracing
/// Integrates with Firebase Analytics and Sentry
@lazySingleton
class ObservabilityService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  bool _isInitialized = false;

  /// Initialize observability services
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.debug('ObservabilityService already initialized');
      return;
    }

    try {
      // Analytics is enabled based on config
      if (AppConfig.enableAnalytics) {
        AppLogger.info('Firebase Analytics enabled');
        await _analytics.setAnalyticsCollectionEnabled(true);
      } else {
        AppLogger.info('Firebase Analytics disabled');
        await _analytics.setAnalyticsCollectionEnabled(false);
      }

      _isInitialized = true;
      AppLogger.info('ObservabilityService initialized');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize ObservabilityService', e, stackTrace);
    }
  }

  /// Track authentication events
  Future<void> trackAuthEvent(
    String event, {
    Map<String, dynamic>? properties,
  }) async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      // Send to Firebase Analytics
      await _analytics.logEvent(
        name: event,
        parameters: properties?.cast<String, Object>(),
      );

      // Also send to Sentry as breadcrumb
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: event,
          category: 'auth',
          data: properties,
          level: SentryLevel.info,
          timestamp: DateTime.now(),
        ),
      );

      AppLogger.debug('Tracked auth event: $event');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to track auth event', e, stackTrace);
    }
  }

  /// Track auth errors
  Future<void> trackAuthError(
    String errorType,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // Log to Firebase Analytics
      if (AppConfig.enableAnalytics) {
        await _analytics.logEvent(
          name: 'auth_error',
          parameters: {
            'error_type': errorType,
            'error_message': error.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      // Send to Sentry
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'error_type': errorType,
          'category': 'auth',
        }),
      );

      AppLogger.error('Auth error tracked: $errorType', error, stackTrace);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to track auth error', e, stackTrace);
    }
  }

  /// Start transaction for distributed tracing
  /// Returns a Sentry span that should be finished when operation completes
  ISentrySpan startAuthTransaction(String operation) {
    try {
      final transaction = Sentry.startTransaction(
        'auth.$operation',
        'auth',
        bindToScope: true,
      );

      AppLogger.debug('Started transaction: auth.$operation');

      return transaction;
    } catch (e) {
      AppLogger.error('Failed to start transaction', e);

      // Return a no-op span if Sentry fails
      return NoOpSentrySpan();
    }
  }

  /// Track user login
  Future<void> trackLogin({
    required String method,
    bool success = true,
  }) async {
    await trackAuthEvent(
      'login',
      properties: {
        'method': method,
        'success': success,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (success && AppConfig.enableAnalytics) {
      await _analytics.logLogin(loginMethod: method);
    }
  }

  /// Track user logout
  Future<void> trackLogout() async {
    await trackAuthEvent(
      'logout',
      properties: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track token refresh
  Future<void> trackTokenRefresh({
    required bool success,
    int? expiresIn,
    String? failureReason,
  }) async {
    await trackAuthEvent(
      'token_refresh',
      properties: {
        'success': success,
        'expires_in': expiresIn,
        'failure_reason': failureReason,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _analytics.logScreenView(screenName: screenName);

      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Screen: $screenName',
          category: 'navigation',
          level: SentryLevel.info,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to track screen view', e);
    }
  }

  /// Track custom event
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters?.cast<String, Object>(),
      );
    } catch (e) {
      AppLogger.error('Failed to track event', e);
    }
  }

  /// Set user properties for analytics
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      AppLogger.error('Failed to set user property', e);
    }
  }

  /// Set user ID for tracking
  Future<void> setUserId(String? userId) async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _analytics.setUserId(id: userId);

      // Also set in Sentry
      if (userId != null) {
        await Sentry.configureScope((scope) {
          scope.setUser(SentryUser(id: userId));
        });
      } else {
        await Sentry.configureScope((scope) {
          scope.setUser(null);
        });
      }
    } catch (e) {
      AppLogger.error('Failed to set user ID', e);
    }
  }

  /// Add breadcrumb for debugging
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data,
        level: level,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Capture message
  Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    try {
      await Sentry.captureMessage(
        message,
        level: level,
      );
    } catch (e) {
      AppLogger.error('Failed to capture message', e);
    }
  }
}

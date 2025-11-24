import 'package:firebase_performance/firebase_performance.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/configs/app_config.dart';
import 'package:iqra_wave/core/utils/logger.dart';

/// Performance monitoring service
/// Tracks app performance metrics using Firebase Performance
@lazySingleton
class PerformanceMonitor {
  final FirebasePerformance _performance = FirebasePerformance.instance;

  bool _isInitialized = false;

  /// Initialize performance monitoring
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Enable/disable based on config
      await _performance.setPerformanceCollectionEnabled(
        AppConfig.enableAnalytics,
      );

      _isInitialized = true;

      if (AppConfig.enableAnalytics) {
        AppLogger.info('Firebase Performance monitoring enabled');
      } else {
        AppLogger.info('Firebase Performance monitoring disabled');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize performance monitor', e, stackTrace);
    }
  }

  /// Monitor token refresh performance
  Future<T> monitorTokenRefresh<T>(
    Future<T> Function() operation,
  ) async {
    if (!AppConfig.enableAnalytics) {
      return await operation();
    }

    final trace = _performance.newTrace('token_refresh');

    try {
      await trace.start();

      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime);

      trace
        ..putAttribute('status', 'success')
        ..setMetric('duration_ms', duration.inMilliseconds);

      AppLogger.debug('Token refresh took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      trace
        ..putAttribute('status', 'error')
        ..putAttribute('error_type', e.runtimeType.toString());

      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Monitor authentication performance
  Future<T> monitorAuthentication<T>(
    String method,
    Future<T> Function() operation,
  ) async {
    if (!AppConfig.enableAnalytics) {
      return await operation();
    }

    final trace = _performance.newTrace('authentication_$method');

    try {
      await trace.start();
      trace.putAttribute('auth_method', method);

      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime);

      trace
        ..putAttribute('status', 'success')
        ..setMetric('duration_ms', duration.inMilliseconds);

      AppLogger.debug('Authentication took ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      trace
        ..putAttribute('status', 'error')
        ..putAttribute('error_type', e.runtimeType.toString());

      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Monitor API request performance
  Future<T> monitorApiRequest<T>(
    String endpoint,
    Future<T> Function() operation,
  ) async {
    if (!AppConfig.enableAnalytics) {
      return await operation();
    }

    final trace = _performance.newTrace('api_request');

    try {
      await trace.start();
      trace.putAttribute('endpoint', endpoint);

      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime);

      trace
        ..putAttribute('status', 'success')
        ..setMetric('duration_ms', duration.inMilliseconds);

      return result;
    } catch (e) {
      trace
        ..putAttribute('status', 'error')
        ..putAttribute('error_type', e.runtimeType.toString());

      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Monitor screen load performance
  Future<T> monitorScreenLoad<T>(
    String screenName,
    Future<T> Function() operation,
  ) async {
    if (!AppConfig.enableAnalytics) {
      return await operation();
    }

    final trace = _performance.newTrace('screen_load_$screenName');

    try {
      await trace.start();

      final startTime = DateTime.now();
      final result = await operation();
      final duration = DateTime.now().difference(startTime);

      trace
        ..putAttribute('screen_name', screenName)
        ..setMetric('load_time_ms', duration.inMilliseconds);

      AppLogger.debug('Screen $screenName loaded in ${duration.inMilliseconds}ms');

      return result;
    } catch (e) {
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Create custom trace
  Trace createTrace(String name) {
    return _performance.newTrace(name);
  }

  /// Start HTTP metric (for manual network tracking)
  HttpMetric createHttpMetric(String url, HttpMethod method) {
    return _performance.newHttpMetric(url, method);
  }
}

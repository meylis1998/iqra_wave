import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/services/token_refresh_manager.dart';
import 'package:iqra_wave/core/services/token_service.dart';
import 'package:iqra_wave/core/utils/logger.dart';

/// Proactive token refresh scheduler
/// Periodically checks token expiry and refreshes before it expires
/// Prevents 401 errors by keeping token fresh
@lazySingleton
class TokenRefreshScheduler {
  TokenRefreshScheduler(
    this._tokenService,
    this._tokenRefreshManager,
  );

  final TokenService _tokenService;
  final TokenRefreshManager _tokenRefreshManager;

  Timer? _refreshTimer;
  Timer? _monitorTimer;

  // Configuration
  static const Duration _checkInterval = Duration(minutes: 1);
  static const int _refreshThresholdSeconds = 600; // 10 minutes
  static const int _urgentRefreshThresholdSeconds = 300; // 5 minutes

  bool _isActive = false;

  /// Start background token refresh monitoring
  /// Checks token expiry every minute and refreshes when needed
  void startProactiveRefresh() {
    if (_isActive) {
      AppLogger.debug('Proactive refresh already active');
      return;
    }

    stopProactiveRefresh(); // Ensure clean state

    AppLogger.info(
      'Starting proactive token refresh '
      '(check interval: ${_checkInterval.inSeconds}s, '
      'refresh threshold: $_refreshThresholdSeconds s)',
    );

    _isActive = true;

    // Start periodic check
    _refreshTimer = Timer.periodic(
      _checkInterval,
      (_) => _checkAndRefresh(),
    );

    // Immediate check
    _checkAndRefresh();
  }

  /// Stop background token refresh
  void stopProactiveRefresh() {
    if (!_isActive) {
      return;
    }

    AppLogger.info('Stopping proactive token refresh');

    _refreshTimer?.cancel();
    _refreshTimer = null;

    _monitorTimer?.cancel();
    _monitorTimer = null;

    _isActive = false;
  }

  /// Check token expiry and refresh if needed
  Future<void> _checkAndRefresh() async {
    if (!_isActive) {
      return;
    }

    try {
      // Check if token exists
      final hasToken = await _tokenService.hasValidToken();

      if (!hasToken) {
        AppLogger.debug('No valid token found - skipping proactive refresh');
        return;
      }

      // Get time until expiry
      final timeUntilExpiry = await _tokenService.getTimeUntilExpiry();

      if (timeUntilExpiry == null) {
        AppLogger.debug('Unable to determine token expiry');
        return;
      }

      AppLogger.debug('Token expires in $timeUntilExpiry seconds');

      // Determine if refresh is needed
      if (timeUntilExpiry < _urgentRefreshThresholdSeconds) {
        AppLogger.warning(
          'Token expires soon ($timeUntilExpiry s). '
          'Triggering urgent refresh...',
        );
        await _performRefresh();
      } else if (timeUntilExpiry < _refreshThresholdSeconds) {
        AppLogger.info(
          'Token approaching expiry ($timeUntilExpiry s). '
          'Triggering proactive refresh...',
        );
        await _performRefresh();
      } else {
        // Token is still fresh
        final minutesRemaining = (timeUntilExpiry / 60).round();
        AppLogger.debug(
          'Token is fresh (~$minutesRemaining minutes remaining)',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error in proactive refresh check', e, stackTrace);
    }
  }

  /// Perform the actual token refresh
  Future<void> _performRefresh() async {
    try {
      // Check if refresh is already in progress
      if (_tokenRefreshManager.isRefreshing) {
        AppLogger.debug('Refresh already in progress - skipping');
        return;
      }

      final result = await _tokenRefreshManager.refreshToken();

      result.fold(
        (failure) {
          AppLogger.error(
            'Proactive token refresh failed: ${failure.message}',
          );

          // Schedule retry after delay if token is about to expire
          _scheduleRetry();
        },
        (token) {
          AppLogger.info(
            'Proactive token refresh successful. '
            'New token expires in ${token.expiresIn} seconds',
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error during proactive refresh', e, stackTrace);
      _scheduleRetry();
    }
  }

  /// Schedule a retry attempt after failure
  void _scheduleRetry() {
    if (!_isActive) {
      return;
    }

    // Cancel existing retry timer
    _monitorTimer?.cancel();

    // Retry after 1 minute
    const retryDelay = Duration(minutes: 1);

    AppLogger.info('Scheduling token refresh retry in ${retryDelay.inSeconds}s');

    _monitorTimer = Timer(retryDelay, () {
      AppLogger.info('Executing scheduled retry');
      _checkAndRefresh();
    });
  }

  /// Force an immediate refresh check
  Future<void> forceRefreshCheck() async {
    AppLogger.info('Force refresh check requested');
    await _checkAndRefresh();
  }

  /// Check if scheduler is active
  bool get isActive => _isActive;

  /// Get current refresh threshold
  int get refreshThresholdSeconds => _refreshThresholdSeconds;

  /// Get urgent refresh threshold
  int get urgentRefreshThresholdSeconds => _urgentRefreshThresholdSeconds;

  /// Get check interval
  Duration get checkInterval => _checkInterval;

  /// Dispose resources
  @disposeMethod
  void dispose() {
    stopProactiveRefresh();
  }
}

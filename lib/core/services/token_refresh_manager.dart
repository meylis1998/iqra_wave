import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/usecase/usecase.dart';
import 'package:iqra_wave/core/utils/logger.dart';
import 'package:iqra_wave/features/auth/domain/entities/token_entity.dart';
import 'package:iqra_wave/features/auth/domain/usecases/get_access_token.dart';
import 'package:synchronized/synchronized.dart';

/// Manages token refresh with proper queuing to prevent race conditions
/// Ensures only one refresh operation happens at a time
/// Multiple simultaneous requests wait for the same refresh to complete
@lazySingleton
class TokenRefreshManager {
  TokenRefreshManager(this._getAccessToken);

  final GetAccessToken _getAccessToken;
  final _lock = Lock();

  // Queue of completers waiting for token refresh
  final List<Completer<TokenEntity>> _refreshQueue = [];

  // Cached refresh future to prevent multiple simultaneous refreshes
  Future<Either<Failure, TokenEntity>>? _refreshFuture;

  // Track last refresh time to prevent excessive refresh attempts
  DateTime? _lastRefreshAttempt;
  static const _minRefreshInterval = Duration(seconds: 5);

  /// Thread-safe token refresh with request queuing
  /// Returns Either<Failure, TokenEntity>
  Future<Either<Failure, TokenEntity>> refreshToken() async {
    return await _lock.synchronized(() async {
      // Check if we're refreshing too frequently
      if (_lastRefreshAttempt != null) {
        final timeSinceLastRefresh =
            DateTime.now().difference(_lastRefreshAttempt!);

        if (timeSinceLastRefresh < _minRefreshInterval) {
          AppLogger.warning(
            'Token refresh requested too soon after previous attempt. '
            'Waiting for cooldown...',
          );
          await Future<void>.delayed(
            _minRefreshInterval - timeSinceLastRefresh,
          );
        }
      }

      // If refresh is already in progress, wait for it
      if (_refreshFuture != null) {
        AppLogger.debug(
          'Token refresh already in progress. '
          'Waiting for existing refresh to complete...',
        );
        return await _refreshFuture!;
      }

      // Start new refresh
      AppLogger.info('Starting token refresh');
      _lastRefreshAttempt = DateTime.now();
      _refreshFuture = _performRefresh();

      try {
        final result = await _refreshFuture!;

        // Notify all waiting requests in queue
        _notifyQueue(result);

        return result;
      } finally {
        _refreshFuture = null;
        _refreshQueue.clear();
      }
    });
  }

  /// Perform the actual refresh operation
  Future<Either<Failure, TokenEntity>> _performRefresh() async {
    try {
      AppLogger.debug('Executing GetAccessToken use case');
      final result = await _getAccessToken(NoParams());

      result.fold(
        (failure) {
          AppLogger.error('Token refresh failed: ${failure.message}');
        },
        (token) {
          AppLogger.info(
            'Token refresh successful. '
            'Expires in ${token.expiresIn} seconds',
          );
        },
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during token refresh', e, stackTrace);
      return Left(UnexpectedFailure('Token refresh failed: $e'));
    }
  }

  /// Notify all queued requests of the refresh result
  void _notifyQueue(Either<Failure, TokenEntity> result) {
    if (_refreshQueue.isEmpty) {
      return;
    }

    AppLogger.debug('Notifying ${_refreshQueue.length} queued requests');

    for (final completer in _refreshQueue) {
      if (!completer.isCompleted) {
        result.fold(
          (failure) => completer.completeError(failure),
          (token) => completer.complete(token),
        );
      }
    }
  }

  /// Add a request to the queue and wait for refresh
  /// This is an alternative to calling refreshToken() directly
  /// Useful when you want to explicitly queue a request
  Future<TokenEntity> waitForRefresh() async {
    final completer = Completer<TokenEntity>();

    await _lock.synchronized(() async {
      _refreshQueue.add(completer);
    });

    AppLogger.debug('Request added to refresh queue');

    try {
      return await completer.future;
    } catch (e) {
      if (e is Failure) {
        AppLogger.error('Queued request failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Check if a refresh is currently in progress
  bool get isRefreshing => _refreshFuture != null;

  /// Get the number of requests waiting in queue
  int get queueLength => _refreshQueue.length;

  /// Get time since last refresh attempt
  Duration? get timeSinceLastRefresh {
    if (_lastRefreshAttempt == null) {
      return null;
    }
    return DateTime.now().difference(_lastRefreshAttempt!);
  }

  /// Clear the refresh state (useful for testing or error recovery)
  Future<void> reset() async {
    await _lock.synchronized(() async {
      _refreshFuture = null;
      _lastRefreshAttempt = null;

      // Complete all pending requests with error
      for (final completer in _refreshQueue) {
        if (!completer.isCompleted) {
          completer.completeError(
            const UnexpectedFailure('Token refresh manager was reset'),
          );
        }
      }

      _refreshQueue.clear();
      AppLogger.debug('TokenRefreshManager reset');
    });
  }
}

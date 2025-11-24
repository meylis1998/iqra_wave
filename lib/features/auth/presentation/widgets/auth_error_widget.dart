import 'package:flutter/material.dart';
import 'package:iqra_wave/core/error/failures.dart';
import 'package:iqra_wave/core/utils/logger.dart';

class AuthErrorWidget extends StatelessWidget {
  const AuthErrorWidget({
    required this.message,
    required this.onRetry,
    this.onViewDetails,
    this.failure,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onViewDetails;
  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo();

    AppLogger.error('Auth error displayed: $message', failure);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  errorInfo.icon,
                  size: 64,
                  color: errorInfo.color,
                ),
                const SizedBox(height: 16),
                Text(
                  errorInfo.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: errorInfo.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  errorInfo.userMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                    if (onViewDetails != null) ...[
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: onViewDetails,
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Details'),
                      ),
                    ],
                  ],
                ),
                if (errorInfo.hint != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorInfo.hint!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ErrorInfo _getErrorInfo() {
    if (failure is NetworkFailure) {
      return const _ErrorInfo(
        icon: Icons.wifi_off,
        color: Colors.orange,
        title: 'No Internet Connection',
        userMessage: 'Please check your network connection and try again.',
        hint: 'Make sure Wi-Fi or mobile data is enabled',
      );
    }

    if (failure is OAuth2Failure) {
      return const _ErrorInfo(
        icon: Icons.cloud_off,
        color: Colors.red,
        title: 'Authentication Server Unavailable',
        userMessage: 'The authentication service is currently unavailable.',
        hint: 'This might be temporary. Please try again in a few moments.',
      );
    }

    if (failure is TokenExpiredFailure) {
      return const _ErrorInfo(
        icon: Icons.timer_off,
        color: Colors.blue,
        title: 'Session Expired',
        userMessage: 'Your session has expired. Refreshing...',
        hint: null,
      );
    }

    if (failure is ServerFailure) {
      return const _ErrorInfo(
        icon: Icons.error_outline,
        color: Colors.red,
        title: 'Server Error',
        userMessage: 'The server encountered an error. Please try again later.',
        hint: 'If the problem persists, contact support',
      );
    }

    // Generic error
    return _ErrorInfo(
      icon: Icons.warning_amber,
      color: Colors.orange,
      title: 'Authentication Error',
      userMessage: message,
      hint: 'Please try again or contact support if the issue persists',
    );
  }
}

class _ErrorInfo {
  const _ErrorInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.userMessage,
    required this.hint,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String userMessage;
  final String? hint;
}

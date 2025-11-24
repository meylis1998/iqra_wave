import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_event.dart';
import 'package:iqra_wave/features/auth/presentation/bloc/auth_state.dart';

class AuthStatusPage extends StatelessWidget {
  const AuthStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OAuth2 Status'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully authenticated'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(state),
                const SizedBox(height: 24),
                if (state is AuthAuthenticated) ...[
                  _buildTokenInfo(state),
                  const SizedBox(height: 24),
                ],
                _buildActionButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(AuthState state) {
    IconData icon;
    Color color;
    String status;
    String message;

    if (state is AuthInitial) {
      icon = Icons.info_outline;
      color = Colors.grey;
      status = 'Initial';
      message = 'Authentication not initialized';
    } else if (state is AuthLoading) {
      icon = Icons.hourglass_empty;
      color = Colors.orange;
      status = 'Loading';
      message = 'Checking authentication...';
    } else if (state is AuthRefreshing) {
      icon = Icons.refresh;
      color = Colors.blue;
      status = 'Refreshing';
      message = 'Refreshing access token...';
    } else if (state is AuthAuthenticated) {
      icon = Icons.check_circle;
      color = Colors.green;
      status = 'Authenticated';
      message = 'Successfully authenticated with Quran.Foundation API';
    } else if (state is AuthUnauthenticated) {
      icon = Icons.warning;
      color = Colors.orange;
      status = 'Unauthenticated';
      message = state.message ?? 'No valid token';
    } else if (state is AuthError) {
      icon = Icons.error;
      color = Colors.red;
      status = 'Error';
      message = state.message;
    } else {
      icon = Icons.help;
      color = Colors.grey;
      status = 'Unknown';
      message = 'Unknown state';
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              status,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInfo(AuthAuthenticated state) {
    final token = state.token;
    final expiryDateTime = token.expiryDateTime;
    final timeUntilExpiry = expiryDateTime.difference(DateTime.now());
    final hoursUntilExpiry = timeUntilExpiry.inHours;
    final minutesUntilExpiry = timeUntilExpiry.inMinutes % 60;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Token Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Token Type', token.tokenType),
            _buildInfoRow('Expires In', '${token.expiresIn} seconds'),
            _buildInfoRow(
              'Expiry Time',
              '${expiryDateTime.hour}:${expiryDateTime.minute.toString().padLeft(2, '0')}',
            ),
            _buildInfoRow(
              'Time Until Expiry',
              '$hoursUntilExpiry hours, $minutesUntilExpiry minutes',
            ),
            const SizedBox(height: 8),
            const Text(
              'Access Token (truncated):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${token.accessToken.substring(0, 50)}...',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading || state is AuthRefreshing;
    final isUnauthenticated =
        state is AuthUnauthenticated || state is AuthError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isUnauthenticated) ...[
          ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(const AuthRequestLogin());
                  },
            icon: const Icon(Icons.login),
            label: const Text('Login / Get Token'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (state is AuthAuthenticated) ...[
          ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(const AuthRefreshToken());
                  },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Token'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(const AuthGetUserInfo());
                  },
            icon: const Icon(Icons.person),
            label: const Text('Get User Info'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(const AuthLogout());
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],

        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(const AuthCheckStatus());
                },
          icon: const Icon(Icons.search),
          label: const Text('Check Status'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}

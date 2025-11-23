# Quran.Foundation OAuth2 Integration

## Overview

This document describes the OAuth2 client_credentials authentication integration with the Quran.Foundation API, following Clean Architecture and BLoC pattern.

## Architecture

The implementation follows Clean Architecture principles with three main layers:

### Domain Layer (`lib/features/auth/domain/`)
- **Entities**: `TokenEntity` - Pure domain object representing an OAuth2 token
- **Repositories**: `AuthRepository` - Interface defining authentication contracts
- **Use Cases**:
  - `GetAccessToken` - Obtains a new access token
  - `RefreshToken` - Refreshes the current token (same as getting new token for client_credentials)

### Data Layer (`lib/features/auth/data/`)
- **Models**: `TokenResponseModel` - Data model with Freezed for JSON serialization
- **Data Sources**: `AuthRemoteDataSource` - Handles OAuth2 API communication
- **Repositories**: `AuthRepositoryImpl` - Implements domain repository interface

### Presentation Layer (`lib/features/auth/presentation/`)
- **BLoC**: `AuthBloc` with events and states for auth lifecycle management
- **Pages**: `AuthStatusPage` - Example UI demonstrating the integration

## Configuration

### Environment Settings (`lib/core/configs/app_config.dart`)

**Pre-Production (Dev/Staging)**:
- OAuth URL: `https://prelive-oauth2.quran.foundation`
- API URL: `https://prelive-api.quran.foundation`
- Client ID: `1025e8c6-f978-4186-aed4-7b82b71ec763`
- Client Secret: `cjBj46-wdJkUr15euqZlsTfbiC`

**Production**:
- OAuth URL: `https://oauth2.quran.foundation`
- API URL: `https://api.quran.foundation`
- Client ID: `4d57db73-0de3-4ff9-8fc5-8ff5ecf51a08`
- Client Secret: `4b9rxwZa80dy21.HUfmSd4fUH7`

> **Security Note**: In production, move secrets to environment variables or secure backend service.

## Core Services

### TokenService (`lib/core/services/token_service.dart`)
Injectable service managing token lifecycle:
- `storeToken()` - Securely stores token with expiry
- `getAccessToken()` - Retrieves stored token
- `isTokenExpired()` - Checks validity with 5-minute buffer
- `hasValidToken()` - Combined check for token existence and validity
- `clearTokens()` - Removes all auth data

### AuthInterceptor (`lib/core/network/interceptors/auth_interceptor.dart`)
Dio interceptor that:
1. Automatically injects `x-auth-token` and `x-client-id` headers
2. Checks token validity before each request
3. Refreshes expired tokens proactively
4. Handles 401 responses with automatic retry
5. Prevents infinite loops on OAuth endpoints

## Authentication Flow

### Initial Authentication (On App Start)
```
App Start → AuthBloc.AuthInitialize → Check Valid Token
  ├─ Token Valid → Use Existing Token
  └─ Token Invalid/Missing → Request New Token → Store Token
```

### Request with Authentication
```
API Request → AuthInterceptor
  ├─ Check Token Validity
  │   ├─ Valid → Add Headers → Continue Request
  │   └─ Expired → Get New Token → Add Headers → Continue Request
  └─ 401 Response → Refresh Token → Retry Request
```

### Token Refresh (Proactive)
- Tokens are checked before each request
- 5-minute buffer before expiration triggers automatic refresh
- Transparent to the application

## Usage

### Accessing Auth State
```dart
// Listen to auth state
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthAuthenticated) {
      // User authenticated, token available
    } else if (state is AuthError) {
      // Handle error
    }
    return YourWidget();
  },
)
```

### Manual Auth Operations
```dart
// Initialize/refresh auth
context.read<AuthBloc>().add(const AuthInitialize());

// Manually refresh token
context.read<AuthBloc>().add(const AuthRefreshToken());

// Check current status
context.read<AuthBloc>().add(const AuthCheckStatus());

// Clear auth data (logout)
context.read<AuthBloc>().add(const AuthLogout());
```

### Making API Calls
API calls automatically include authentication headers through the interceptor:
```dart
// No manual token handling needed
final response = await apiClient.getSomeData();
```

## Headers Added to Requests

Every API request (except OAuth endpoints) includes:
- `x-auth-token`: JWT access token
- `x-client-id`: OAuth client ID

## Security Features

1. **Secure Storage**: Tokens stored in FlutterSecureStorage
2. **Proactive Refresh**: 5-minute buffer prevents expired token usage
3. **Automatic Retry**: Failed requests due to token issues are retried once
4. **Token Validation**: Checked before each request
5. **Expiry Tracking**: Timestamp-based expiration monitoring

## Testing

### Unit Tests Location
- `test/features/auth/domain/usecases/` - Use case tests
- `test/features/auth/data/repositories/` - Repository tests
- `test/features/auth/presentation/bloc/` - BLoC tests

### Testing Strategy
1. **Use Cases**: Test with mock repositories
2. **Repositories**: Test with mock data sources
3. **BLoC**: Test state transitions with mock use cases
4. **Data Sources**: Integration tests with test environment

## Example Screen

Navigate to `AuthStatusPage` to see:
- Current authentication status
- Token information (type, expiry, time remaining)
- Manual control buttons (initialize, refresh, check, logout)

## Error Handling

### Failure Types (`lib/core/error/failures.dart`)
- `OAuth2Failure` - OAuth2-specific errors
- `TokenExpiredFailure` - Token expiration
- `AuthenticationFailure` - General auth failures
- `NetworkFailure` - Network connectivity issues
- `ServerFailure` - Server-side errors

### Exception Handling
All exceptions are caught at the repository layer and converted to appropriate Failures using the Either monad from dartz.

## Logging

All OAuth operations are logged using AppLogger:
- Token requests and responses
- Header injection
- Token expiration checks
- Refresh operations
- Error conditions

## Dependencies

### Required Packages
- `dio` - HTTP client
- `flutter_secure_storage` - Secure token storage
- `flutter_bloc` - State management
- `injectable` / `get_it` - Dependency injection
- `dartz` - Functional programming (Either monad)
- `freezed` - Code generation for models
- `equatable` - Value equality

## Troubleshooting

### Token Not Being Added to Requests
- Check `AuthBloc` is initialized in main.dart
- Verify `AuthInitialize` event is dispatched on startup
- Check logs for token storage/retrieval errors

### 401 Errors Despite Valid Token
- Verify client credentials match environment
- Check token format in secure storage
- Ensure headers are correctly formatted

### Token Refresh Loop
- Check for circular dependency in interceptor
- Verify OAuth endpoints are excluded from interception
- Review `_isRefreshing` flag logic

## Future Improvements

1. **Environment Variables**: Move secrets to .env file
2. **Circuit Breaker**: Implement exponential backoff for OAuth failures
3. **Token Metrics**: Track token refresh frequency and failures
4. **Offline Support**: Cache tokens with encryption for offline scenarios
5. **Multi-Environment**: Support switching environments at runtime

## API Documentation

For full API documentation, visit:
- Test Environment: https://prelive-oauth2.quran.foundation
- Production: https://oauth2.quran.foundation

## Support

For issues or questions:
1. Check logs in debug console (all operations are logged)
2. Use `AuthStatusPage` to verify current state
3. Review this documentation
4. Check Quran.Foundation API documentation

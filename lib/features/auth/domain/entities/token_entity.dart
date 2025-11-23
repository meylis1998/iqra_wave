import 'package:equatable/equatable.dart';

/// Domain entity representing an OAuth2 access token
/// This is a pure domain object with no dependencies on external packages
class TokenEntity extends Equatable {
  const TokenEntity({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.issuedAt,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final int issuedAt;

  /// Check if the token is expired with a buffer time
  bool isExpired({int bufferSeconds = 300}) {
    if (issuedAt == 0) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiryTime = issuedAt + expiresIn;
    return now >= (expiryTime - bufferSeconds);
  }

  /// Get the expiry timestamp (Unix timestamp in seconds)
  int get expiryTimestamp => issuedAt + expiresIn;

  /// Get the expiry DateTime
  DateTime get expiryDateTime =>
      DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);

  @override
  List<Object?> get props => [accessToken, tokenType, expiresIn, issuedAt];
}

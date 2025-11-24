import 'package:equatable/equatable.dart';

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

  bool isExpired({int bufferSeconds = 300}) {
    if (issuedAt == 0) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiryTime = issuedAt + expiresIn;
    return now >= (expiryTime - bufferSeconds);
  }

  int get expiryTimestamp => issuedAt + expiresIn;

  DateTime get expiryDateTime =>
      DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);

  @override
  List<Object?> get props => [accessToken, tokenType, expiresIn, issuedAt];
}

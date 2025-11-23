import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_response_model.freezed.dart';
part 'token_response_model.g.dart';

/// OAuth2 token response model for Quran.Foundation API
/// Represents the access token received from the OAuth2 server
@freezed
class TokenResponseModel with _$TokenResponseModel {
  const factory TokenResponseModel({
    /// The access token string (JWT)
    @JsonKey(name: 'access_token') required String accessToken,

    /// The type of token (usually "Bearer")
    @JsonKey(name: 'token_type') required String tokenType,

    /// Number of seconds until the token expires
    @JsonKey(name: 'expires_in') required int expiresIn,

    /// Timestamp when the token was issued (calculated locally)
    /// Used to determine if the token has expired
    @Default(0) int issuedAt,
  }) = _TokenResponseModel;

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseModelFromJson(json);

  const TokenResponseModel._();

  /// Check if the token is expired with a buffer time (default 5 minutes)
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
}

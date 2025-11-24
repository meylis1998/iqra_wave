import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_response_model.freezed.dart';
part 'token_response_model.g.dart';

@freezed
class TokenResponseModel with _$TokenResponseModel {
  const factory TokenResponseModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: 'expires_in') required int expiresIn,
    String? scope,
    @Default(0) int issuedAt,
  }) = _TokenResponseModel;

  const TokenResponseModel._();

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseModelFromJson(json);

  bool isExpired({int bufferSeconds = 300}) {
    if (issuedAt == 0) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiryTime = issuedAt + expiresIn;
    return now >= (expiryTime - bufferSeconds);
  }

  int get expiryTimestamp => issuedAt + expiresIn;

  DateTime get expiryDateTime =>
      DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenResponseModel _$TokenResponseModelFromJson(Map<String, dynamic> json) =>
    _TokenResponseModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      scope: json['scope'] as String?,
      issuedAt: (json['issuedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TokenResponseModelToJson(_TokenResponseModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'scope': instance.scope,
      'issuedAt': instance.issuedAt,
    };

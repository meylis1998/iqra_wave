// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenResponseModelImpl _$$TokenResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenResponseModelImpl(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      issuedAt: (json['issuedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TokenResponseModelImplToJson(
        _$TokenResponseModelImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'issuedAt': instance.issuedAt,
    };

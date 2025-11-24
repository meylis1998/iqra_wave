// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TokenResponseModel _$TokenResponseModelFromJson(Map<String, dynamic> json) {
  return _TokenResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TokenResponseModel {
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'token_type')
  String get tokenType => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_in')
  int get expiresIn => throw _privateConstructorUsedError;
  String? get scope => throw _privateConstructorUsedError;
  int get issuedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TokenResponseModelCopyWith<TokenResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenResponseModelCopyWith<$Res> {
  factory $TokenResponseModelCopyWith(
          TokenResponseModel value, $Res Function(TokenResponseModel) then) =
      _$TokenResponseModelCopyWithImpl<$Res, TokenResponseModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'expires_in') int expiresIn,
      String? scope,
      int issuedAt});
}

/// @nodoc
class _$TokenResponseModelCopyWithImpl<$Res, $Val extends TokenResponseModel>
    implements $TokenResponseModelCopyWith<$Res> {
  _$TokenResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? expiresIn = null,
    Object? scope = freezed,
    Object? issuedAt = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      scope: freezed == scope
          ? _value.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String?,
      issuedAt: null == issuedAt
          ? _value.issuedAt
          : issuedAt // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenResponseModelImplCopyWith<$Res>
    implements $TokenResponseModelCopyWith<$Res> {
  factory _$$TokenResponseModelImplCopyWith(_$TokenResponseModelImpl value,
          $Res Function(_$TokenResponseModelImpl) then) =
      __$$TokenResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'expires_in') int expiresIn,
      String? scope,
      int issuedAt});
}

/// @nodoc
class __$$TokenResponseModelImplCopyWithImpl<$Res>
    extends _$TokenResponseModelCopyWithImpl<$Res, _$TokenResponseModelImpl>
    implements _$$TokenResponseModelImplCopyWith<$Res> {
  __$$TokenResponseModelImplCopyWithImpl(_$TokenResponseModelImpl _value,
      $Res Function(_$TokenResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? tokenType = null,
    Object? expiresIn = null,
    Object? scope = freezed,
    Object? issuedAt = null,
  }) {
    return _then(_$TokenResponseModelImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      scope: freezed == scope
          ? _value.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String?,
      issuedAt: null == issuedAt
          ? _value.issuedAt
          : issuedAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenResponseModelImpl extends _TokenResponseModel {
  const _$TokenResponseModelImpl(
      {@JsonKey(name: 'access_token') required this.accessToken,
      @JsonKey(name: 'token_type') required this.tokenType,
      @JsonKey(name: 'expires_in') required this.expiresIn,
      this.scope,
      this.issuedAt = 0})
      : super._();

  factory _$TokenResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenResponseModelImplFromJson(json);

  @override
  @JsonKey(name: 'access_token')
  final String accessToken;
  @override
  @JsonKey(name: 'token_type')
  final String tokenType;
  @override
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  @override
  final String? scope;
  @override
  @JsonKey()
  final int issuedAt;

  @override
  String toString() {
    return 'TokenResponseModel(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn, scope: $scope, issuedAt: $issuedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenResponseModelImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            (identical(other.issuedAt, issuedAt) ||
                other.issuedAt == issuedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, accessToken, tokenType, expiresIn, scope, issuedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenResponseModelImplCopyWith<_$TokenResponseModelImpl> get copyWith =>
      __$$TokenResponseModelImplCopyWithImpl<_$TokenResponseModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenResponseModelImplToJson(
      this,
    );
  }
}

abstract class _TokenResponseModel extends TokenResponseModel {
  const factory _TokenResponseModel(
      {@JsonKey(name: 'access_token') required final String accessToken,
      @JsonKey(name: 'token_type') required final String tokenType,
      @JsonKey(name: 'expires_in') required final int expiresIn,
      final String? scope,
      final int issuedAt}) = _$TokenResponseModelImpl;
  const _TokenResponseModel._() : super._();

  factory _TokenResponseModel.fromJson(Map<String, dynamic> json) =
      _$TokenResponseModelImpl.fromJson;

  @override
  @JsonKey(name: 'access_token')
  String get accessToken;
  @override
  @JsonKey(name: 'token_type')
  String get tokenType;
  @override
  @JsonKey(name: 'expires_in')
  int get expiresIn;
  @override
  String? get scope;
  @override
  int get issuedAt;
  @override
  @JsonKey(ignore: true)
  _$$TokenResponseModelImplCopyWith<_$TokenResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

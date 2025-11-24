// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TokenResponseModel {

@JsonKey(name: 'access_token') String get accessToken;@JsonKey(name: 'token_type') String get tokenType;@JsonKey(name: 'expires_in') int get expiresIn; String? get scope; int get issuedAt;
/// Create a copy of TokenResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenResponseModelCopyWith<TokenResponseModel> get copyWith => _$TokenResponseModelCopyWithImpl<TokenResponseModel>(this as TokenResponseModel, _$identity);

  /// Serializes this TokenResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenResponseModel&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,tokenType,expiresIn,scope,issuedAt);

@override
String toString() {
  return 'TokenResponseModel(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn, scope: $scope, issuedAt: $issuedAt)';
}


}

/// @nodoc
abstract mixin class $TokenResponseModelCopyWith<$Res>  {
  factory $TokenResponseModelCopyWith(TokenResponseModel value, $Res Function(TokenResponseModel) _then) = _$TokenResponseModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'token_type') String tokenType,@JsonKey(name: 'expires_in') int expiresIn, String? scope, int issuedAt
});




}
/// @nodoc
class _$TokenResponseModelCopyWithImpl<$Res>
    implements $TokenResponseModelCopyWith<$Res> {
  _$TokenResponseModelCopyWithImpl(this._self, this._then);

  final TokenResponseModel _self;
  final $Res Function(TokenResponseModel) _then;

/// Create a copy of TokenResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? tokenType = null,Object? expiresIn = null,Object? scope = freezed,Object? issuedAt = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenResponseModel].
extension TokenResponseModelPatterns on TokenResponseModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenResponseModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _TokenResponseModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _TokenResponseModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn,  String? scope,  int issuedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenResponseModel() when $default != null:
return $default(_that.accessToken,_that.tokenType,_that.expiresIn,_that.scope,_that.issuedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn,  String? scope,  int issuedAt)  $default,) {final _that = this;
switch (_that) {
case _TokenResponseModel():
return $default(_that.accessToken,_that.tokenType,_that.expiresIn,_that.scope,_that.issuedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn,  String? scope,  int issuedAt)?  $default,) {final _that = this;
switch (_that) {
case _TokenResponseModel() when $default != null:
return $default(_that.accessToken,_that.tokenType,_that.expiresIn,_that.scope,_that.issuedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenResponseModel extends TokenResponseModel {
  const _TokenResponseModel({@JsonKey(name: 'access_token') required this.accessToken, @JsonKey(name: 'token_type') required this.tokenType, @JsonKey(name: 'expires_in') required this.expiresIn, this.scope, this.issuedAt = 0}): super._();
  factory _TokenResponseModel.fromJson(Map<String, dynamic> json) => _$TokenResponseModelFromJson(json);

@override@JsonKey(name: 'access_token') final  String accessToken;
@override@JsonKey(name: 'token_type') final  String tokenType;
@override@JsonKey(name: 'expires_in') final  int expiresIn;
@override final  String? scope;
@override@JsonKey() final  int issuedAt;

/// Create a copy of TokenResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenResponseModelCopyWith<_TokenResponseModel> get copyWith => __$TokenResponseModelCopyWithImpl<_TokenResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenResponseModel&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,tokenType,expiresIn,scope,issuedAt);

@override
String toString() {
  return 'TokenResponseModel(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn, scope: $scope, issuedAt: $issuedAt)';
}


}

/// @nodoc
abstract mixin class _$TokenResponseModelCopyWith<$Res> implements $TokenResponseModelCopyWith<$Res> {
  factory _$TokenResponseModelCopyWith(_TokenResponseModel value, $Res Function(_TokenResponseModel) _then) = __$TokenResponseModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'token_type') String tokenType,@JsonKey(name: 'expires_in') int expiresIn, String? scope, int issuedAt
});




}
/// @nodoc
class __$TokenResponseModelCopyWithImpl<$Res>
    implements _$TokenResponseModelCopyWith<$Res> {
  __$TokenResponseModelCopyWithImpl(this._self, this._then);

  final _TokenResponseModel _self;
  final $Res Function(_TokenResponseModel) _then;

/// Create a copy of TokenResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? tokenType = null,Object? expiresIn = null,Object? scope = freezed,Object? issuedAt = null,}) {
  return _then(_TokenResponseModel(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

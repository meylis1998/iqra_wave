import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';

part 'user_info_model.freezed.dart';
part 'user_info_model.g.dart';

/// OpenID Connect UserInfo model for Quran.Foundation API
/// Represents user information from the /userinfo endpoint
@freezed
class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    /// User's email address (RFC 5322 format)
    required String email,

    /// User's first name
    @JsonKey(name: 'first_name') String? firstName,

    /// User's last name
    @JsonKey(name: 'last_name') String? lastName,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);

  const UserInfoModel._();

  /// Convert model to domain entity
  UserInfoEntity toEntity() {
    return UserInfoEntity(
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Get full name (first name + last name)
  String get fullName {
    final parts = <String>[];
    if (firstName != null && firstName!.isNotEmpty) {
      parts.add(firstName!);
    }
    if (lastName != null && lastName!.isNotEmpty) {
      parts.add(lastName!);
    }
    return parts.isEmpty ? email : parts.join(' ');
  }
}

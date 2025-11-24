import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:iqra_wave/features/auth/domain/entities/user_info_entity.dart';

part 'user_info_model.freezed.dart';
part 'user_info_model.g.dart';

@freezed
class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    required String email,

    @JsonKey(name: 'first_name') String? firstName,

    @JsonKey(name: 'last_name') String? lastName,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);

  const UserInfoModel._();

  UserInfoEntity toEntity() {
    return UserInfoEntity(
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }

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

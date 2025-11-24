import 'package:equatable/equatable.dart';

class UserInfoEntity extends Equatable {
  const UserInfoEntity({
    required this.email,
    this.firstName,
    this.lastName,
  });

  final String email;
  final String? firstName;
  final String? lastName;

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

  String get displayName => fullName.isNotEmpty ? fullName : email;

  @override
  List<Object?> get props => [email, firstName, lastName];

  @override
  String toString() =>
      'UserInfoEntity(email: $email, firstName: $firstName, lastName: $lastName)';
}

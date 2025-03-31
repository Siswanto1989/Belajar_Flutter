import 'package:hive/hive.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
enum UserRole {
  @HiveField(0)
  admin,
  
  @HiveField(1)
  foreman,
  
  @HiveField(2)
  inspector,
}

@HiveType(typeId: 9)
class UserModel extends User {
  @HiveField(0)
  @override
  final String id;
  
  @HiveField(1)
  @override
  final String name;
  
  @HiveField(2)
  @override
  final String pin;
  
  @HiveField(3)
  @override
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.pin,
    required this.role,
  }) : super(
          id: id,
          name: name,
          pin: pin,
          role: role,
        );

  factory UserModel.fromUser(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      pin: user.pin,
      role: user.role,
    );
  }

  // Helper method to convert role to string
  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.foreman:
        return 'Foreman';
      case UserRole.inspector:
        return 'Inspector';
    }
  }

  // Helper method to convert string to role
  static UserRole stringToRole(String role) {
    switch (role) {
      case 'Admin':
        return UserRole.admin;
      case 'Foreman':
        return UserRole.foreman;
      case 'Inspector':
        return UserRole.inspector;
      default:
        return UserRole.inspector;
    }
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? pin,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pin: pin ?? this.pin,
      role: role ?? this.role,
    );
  }
}

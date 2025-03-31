import '../../data/models/user_model.dart';

class User {
  final String id;
  final String name;
  final String pin;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.pin,
    required this.role,
  });
  
  bool get isAdmin => role == UserRole.admin;
  bool get isForeman => role == UserRole.foreman;
  bool get isInspector => role == UserRole.inspector;
  
  String get roleString {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.foreman:
        return 'Foreman';
      case UserRole.inspector:
        return 'Inspector';
    }
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, role: $role}';
  }
}

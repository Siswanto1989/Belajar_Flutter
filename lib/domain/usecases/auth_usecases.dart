import '../entities/user.dart';
import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthUseCases {
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final CheckAuthentication checkAuthentication;
  final VerifyAdminPin verifyAdminPin;

  AuthUseCases({
    required this.loginUser,
    required this.logoutUser,
    required this.checkAuthentication,
    required this.verifyAdminPin,
  });
}

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<bool> call(String pin, UserRole role) async {
    return await repository.loginUser(pin, role);
  }
}

class LogoutUser {
  final AuthRepository repository;

  LogoutUser(this.repository);

  Future<void> call() async {
    await repository.logoutUser();
  }
}

class CheckAuthentication {
  final AuthRepository repository;

  CheckAuthentication(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}

class VerifyAdminPin {
  final AuthRepository repository;

  VerifyAdminPin(this.repository);

  Future<bool> call(String pin) async {
    return await repository.verifyAdminPin(pin);
  }
}

import '../entities/user.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<bool> loginUser(String pin, UserRole role);
  Future<void> logoutUser();
  Future<bool> verifyAdminPin(String pin);
  Future<bool> isAuthenticated();
}

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await localDataSource.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user');
    }
  }

  @override
  Future<bool> loginUser(String pin, UserRole role) async {
    try {
      return await localDataSource.loginUser(pin, role);
    } catch (e) {
      throw Exception('Failed to login user');
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      await localDataSource.logoutUser();
    } catch (e) {
      throw Exception('Failed to logout user');
    }
  }

  @override
  Future<bool> verifyAdminPin(String pin) async {
    try {
      return await localDataSource.verifyAdminPin(pin);
    } catch (e) {
      throw Exception('Failed to verify admin PIN');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = await localDataSource.getCurrentUser();
      return user != null;
    } catch (e) {
      throw Exception('Failed to check authentication status');
    }
  }
}

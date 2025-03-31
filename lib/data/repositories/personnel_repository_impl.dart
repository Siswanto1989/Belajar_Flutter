import '../../domain/entities/personnel.dart';
import '../../domain/repositories/personnel_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/personnel_model.dart';

class PersonnelRepositoryImpl implements PersonnelRepository {
  final LocalDataSource localDataSource;

  PersonnelRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Personnel>> getAllPersonnel() async {
    try {
      return await localDataSource.getAllPersonnel();
    } catch (e) {
      throw Exception('Failed to get all personnel');
    }
  }

  @override
  Future<List<Personnel>> getPersonnelByGroup(String group) async {
    try {
      return await localDataSource.getPersonnelByGroup(group);
    } catch (e) {
      throw Exception('Failed to get personnel by group');
    }
  }

  @override
  Future<void> addPersonnel(Personnel personnel) async {
    try {
      await localDataSource.addPersonnel(
        PersonnelModel.fromPersonnel(personnel),
      );
    } catch (e) {
      throw Exception('Failed to add personnel');
    }
  }

  @override
  Future<void> updatePersonnel(Personnel personnel) async {
    try {
      await localDataSource.updatePersonnel(
        PersonnelModel.fromPersonnel(personnel),
      );
    } catch (e) {
      throw Exception('Failed to update personnel');
    }
  }

  @override
  Future<void> removePersonnel(String id) async {
    try {
      await localDataSource.removePersonnel(id);
    } catch (e) {
      throw Exception('Failed to remove personnel');
    }
  }

  @override
  Future<void> movePersonnel(String personnelId, String newGroup, String newRole) async {
    try {
      await localDataSource.movePersonnel(personnelId, newGroup, newRole);
    } catch (e) {
      throw Exception('Failed to move personnel');
    }
  }

  @override
  Future<void> initializeDefaultPersonnel() async {
    try {
      await localDataSource.initializeDefaultPersonnel();
    } catch (e) {
      throw Exception('Failed to initialize default personnel');
    }
  }
}

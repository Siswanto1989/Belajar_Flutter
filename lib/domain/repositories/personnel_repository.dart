import '../entities/personnel.dart';

abstract class PersonnelRepository {
  Future<List<Personnel>> getAllPersonnel();
  Future<List<Personnel>> getPersonnelByGroup(String group);
  Future<void> addPersonnel(Personnel personnel);
  Future<void> updatePersonnel(Personnel personnel);
  Future<void> removePersonnel(String id);
  Future<void> movePersonnel(String personnelId, String newGroup, String newRole);
  Future<void> initializeDefaultPersonnel();
}

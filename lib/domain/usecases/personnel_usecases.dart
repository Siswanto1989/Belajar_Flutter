import '../entities/personnel.dart';
import '../repositories/personnel_repository.dart';

class PersonnelUseCases {
  final GetAllPersonnel getAllPersonnel;
  final GetPersonnelByGroup getPersonnelByGroup;
  final AddPersonnel addPersonnel;
  final UpdatePersonnel updatePersonnel;
  final RemovePersonnel removePersonnel;
  final MovePersonnel movePersonnel;

  PersonnelUseCases({
    required this.getAllPersonnel,
    required this.getPersonnelByGroup,
    required this.addPersonnel,
    required this.updatePersonnel,
    required this.removePersonnel,
    required this.movePersonnel,
  });
}

class GetAllPersonnel {
  final PersonnelRepository repository;

  GetAllPersonnel(this.repository);

  Future<List<Personnel>> call() async {
    return await repository.getAllPersonnel();
  }
}

class GetPersonnelByGroup {
  final PersonnelRepository repository;

  GetPersonnelByGroup(this.repository);

  Future<List<Personnel>> call(String group) async {
    return await repository.getPersonnelByGroup(group);
  }
}

class AddPersonnel {
  final PersonnelRepository repository;

  AddPersonnel(this.repository);

  Future<void> call(Personnel personnel) async {
    await repository.addPersonnel(personnel);
  }
}

class UpdatePersonnel {
  final PersonnelRepository repository;

  UpdatePersonnel(this.repository);

  Future<void> call(Personnel personnel) async {
    await repository.updatePersonnel(personnel);
  }
}

class RemovePersonnel {
  final PersonnelRepository repository;

  RemovePersonnel(this.repository);

  Future<void> call(String id) async {
    await repository.removePersonnel(id);
  }
}

class MovePersonnel {
  final PersonnelRepository repository;

  MovePersonnel(this.repository);

  Future<void> call(String personnelId, String newGroup, String newRole) async {
    await repository.movePersonnel(personnelId, newGroup, newRole);
  }
}

import 'package:hive/hive.dart';

import '../../domain/entities/personnel.dart';

part 'personnel_model.g.dart';

@HiveType(typeId: 1)
enum PersonnelStatus {
  @HiveField(0)
  present,
  
  @HiveField(1)
  sick,
  
  @HiveField(2)
  permission,
  
  @HiveField(3)
  leave,
}

@HiveType(typeId: 2)
class PersonnelModel extends Personnel {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final String role;

  @HiveField(3)
  @override
  final String group;

  @HiveField(4)
  @override
  final PersonnelStatus status;

  PersonnelModel({
    required this.id,
    required this.name,
    required this.role,
    required this.group,
    this.status = PersonnelStatus.present,
  }) : super(
          id: id,
          name: name,
          role: role,
          group: group,
          status: status,
        );

  factory PersonnelModel.fromPersonnel(Personnel personnel) {
    return PersonnelModel(
      id: personnel.id,
      name: personnel.name,
      role: personnel.role,
      group: personnel.group,
      status: personnel.status,
    );
  }

  // Helper method to convert status to string
  static String statusToString(PersonnelStatus status) {
    switch (status) {
      case PersonnelStatus.present:
        return 'Hadir';
      case PersonnelStatus.sick:
        return 'Sakit';
      case PersonnelStatus.permission:
        return 'Izin';
      case PersonnelStatus.leave:
        return 'Cuti';
    }
  }

  // Helper method to convert string to status
  static PersonnelStatus stringToStatus(String status) {
    switch (status) {
      case 'Hadir':
        return PersonnelStatus.present;
      case 'Sakit':
        return PersonnelStatus.sick;
      case 'Izin':
        return PersonnelStatus.permission;
      case 'Cuti':
        return PersonnelStatus.leave;
      default:
        return PersonnelStatus.present;
    }
  }

  PersonnelModel copyWith({
    String? id,
    String? name,
    String? role,
    String? group,
    PersonnelStatus? status,
  }) {
    return PersonnelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      group: group ?? this.group,
      status: status ?? this.status,
    );
  }
}

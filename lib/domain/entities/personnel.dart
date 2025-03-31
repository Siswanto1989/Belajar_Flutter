import '../../data/models/personnel_model.dart';

class Personnel {
  final String id;
  final String name;
  final String role;
  final String group;
  final PersonnelStatus status;

  Personnel({
    required this.id,
    required this.name,
    required this.role,
    required this.group,
    this.status = PersonnelStatus.present,
  });

  String get statusString {
    switch (status) {
      case PersonnelStatus.present:
        return '';
      case PersonnelStatus.sick:
        return 'Sakit';
      case PersonnelStatus.permission:
        return 'Izin';
      case PersonnelStatus.leave:
        return 'Cuti';
    }
  }
  
  bool get isPresent => status == PersonnelStatus.present;

  @override
  String toString() {
    return 'Personnel{id: $id, name: $name, role: $role, group: $group, status: $status}';
  }
  
  // Add copyWith method
  Personnel copyWith({
    String? id,
    String? name,
    String? role,
    String? group,
    PersonnelStatus? status,
  }) {
    return Personnel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      group: group ?? this.group,
      status: status ?? this.status,
    );
  }
  
  // Add static method to convert status to string
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
}

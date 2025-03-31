// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personnel_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonnelStatusAdapter extends TypeAdapter<PersonnelStatus> {
  @override
  final int typeId = 1;

  @override
  PersonnelStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PersonnelStatus.present;
      case 1:
        return PersonnelStatus.sick;
      case 2:
        return PersonnelStatus.permission;
      case 3:
        return PersonnelStatus.leave;
      default:
        return PersonnelStatus.present;
    }
  }

  @override
  void write(BinaryWriter writer, PersonnelStatus obj) {
    switch (obj) {
      case PersonnelStatus.present:
        writer.writeByte(0);
        break;
      case PersonnelStatus.sick:
        writer.writeByte(1);
        break;
      case PersonnelStatus.permission:
        writer.writeByte(2);
        break;
      case PersonnelStatus.leave:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonnelStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PersonnelModelAdapter extends TypeAdapter<PersonnelModel> {
  @override
  final int typeId = 2;

  @override
  PersonnelModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonnelModel(
      id: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as String,
      group: fields[3] as String,
      status: fields[4] as PersonnelStatus,
    );
  }

  @override
  void write(BinaryWriter writer, PersonnelModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.group)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonnelModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

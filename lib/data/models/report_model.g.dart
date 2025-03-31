// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftTypeAdapter extends TypeAdapter<ShiftType> {
  @override
  final int typeId = 3;

  @override
  ShiftType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShiftType.shift1;
      case 1:
        return ShiftType.shift2;
      case 2:
        return ShiftType.shift3;
      default:
        return ShiftType.shift1;
    }
  }

  @override
  void write(BinaryWriter writer, ShiftType obj) {
    switch (obj) {
      case ShiftType.shift1:
        writer.writeByte(0);
        break;
      case ShiftType.shift2:
        writer.writeByte(1);
        break;
      case ShiftType.shift3:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentStatusAdapter extends TypeAdapter<EquipmentStatus> {
  @override
  final int typeId = 4;

  @override
  EquipmentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EquipmentStatus.ok;
      case 1:
        return EquipmentStatus.notOk;
      default:
        return EquipmentStatus.ok;
    }
  }

  @override
  void write(BinaryWriter writer, EquipmentStatus obj) {
    switch (obj) {
      case EquipmentStatus.ok:
        writer.writeByte(0);
        break;
      case EquipmentStatus.notOk:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SafetyTalkStatusAdapter extends TypeAdapter<SafetyTalkStatus> {
  @override
  final int typeId = 5;

  @override
  SafetyTalkStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SafetyTalkStatus.conducted;
      case 1:
        return SafetyTalkStatus.notConducted;
      default:
        return SafetyTalkStatus.conducted;
    }
  }

  @override
  void write(BinaryWriter writer, SafetyTalkStatus obj) {
    switch (obj) {
      case SafetyTalkStatus.conducted:
        writer.writeByte(0);
        break;
      case SafetyTalkStatus.notConducted:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyTalkStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialReportAdapter extends TypeAdapter<MaterialReport> {
  @override
  final int typeId = 6;

  @override
  MaterialReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialReport(
      type: fields[0] as String,
      bundles: fields[1] as int,
      tonnage: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialReport obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.bundles)
      ..writeByte(2)
      ..write(obj.tonnage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReinspectionAdapter extends TypeAdapter<Reinspection> {
  @override
  final int typeId = 7;

  @override
  Reinspection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reinspection(
      name: fields[0] as String,
      totalBundles: fields[1] as int,
      reinspectedBundles: fields[2] as int,
      pendingBundles: fields[3] as int,
      issue: fields[4] as String?,
      followUp: fields[5] as String?,
      remark: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Reinspection obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.totalBundles)
      ..writeByte(2)
      ..write(obj.reinspectedBundles)
      ..writeByte(3)
      ..write(obj.pendingBundles)
      ..writeByte(4)
      ..write(obj.issue)
      ..writeByte(5)
      ..write(obj.followUp)
      ..writeByte(6)
      ..write(obj.remark);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReinspectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportModelAdapter extends TypeAdapter<ReportModel> {
  @override
  final int typeId = 8;

  @override
  ReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      shift: fields[2] as String,
      foreman: fields[3] as PersonnelModel,
      inspector1: fields[4] as PersonnelModel,
      inspector2: fields[5] as PersonnelModel,
      inspector3: fields[6] as PersonnelModel,
      overtimePersonnel: (fields[7] as List?)?.cast<PersonnelModel>(),
      safetyTalk: fields[8] as SafetyTalkStatus,
      measuringTools: fields[9] as EquipmentStatus,
      flashlight: fields[10] as EquipmentStatus,
      mobilePhone: fields[11] as EquipmentStatus,
      camera: fields[12] as EquipmentStatus,
      usageDecision: fields[13] as MaterialSection?,
      shipmentHR: fields[14] as MaterialSection?,
      preDelivery: fields[15] as MaterialSection?,
      reinspections: (fields[16] as List?)?.cast<Reinspection>(),
      udIssue: fields[17] as String?,
      udFollowUp: fields[18] as String?,
      udRemark: fields[19] as String?,
      createdBy: fields[20] as String,
      createdAt: fields[21] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReportModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.shift)
      ..writeByte(3)
      ..write(obj.foreman)
      ..writeByte(4)
      ..write(obj.inspector1)
      ..writeByte(5)
      ..write(obj.inspector2)
      ..writeByte(6)
      ..write(obj.inspector3)
      ..writeByte(7)
      ..write(obj.overtimePersonnel)
      ..writeByte(8)
      ..write(obj.safetyTalk)
      ..writeByte(9)
      ..write(obj.measuringTools)
      ..writeByte(10)
      ..write(obj.flashlight)
      ..writeByte(11)
      ..write(obj.mobilePhone)
      ..writeByte(12)
      ..write(obj.camera)
      ..writeByte(13)
      ..write(obj.usageDecision)
      ..writeByte(14)
      ..write(obj.shipmentHR)
      ..writeByte(15)
      ..write(obj.preDelivery)
      ..writeByte(16)
      ..write(obj.reinspections)
      ..writeByte(17)
      ..write(obj.udIssue)
      ..writeByte(18)
      ..write(obj.udFollowUp)
      ..writeByte(19)
      ..write(obj.udRemark)
      ..writeByte(20)
      ..write(obj.createdBy)
      ..writeByte(21)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

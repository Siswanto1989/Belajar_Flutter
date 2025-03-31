import 'package:hive/hive.dart';

import '../../domain/entities/report.dart';
import 'personnel_model.dart';

part 'report_model.g.dart';

@HiveType(typeId: 3)
enum ShiftType {
  @HiveField(0)
  shift1,

  @HiveField(1)
  shift2,

  @HiveField(2)
  shift3,
}

@HiveType(typeId: 4)
enum EquipmentStatus {
  @HiveField(0)
  ok,

  @HiveField(1)
  notOk,
}

@HiveType(typeId: 5)
enum SafetyTalkStatus {
  @HiveField(0)
  conducted,

  @HiveField(1)
  notConducted,
}

@HiveType(typeId: 6)
class MaterialReport {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final int bundles;

  @HiveField(2)
  final double tonnage;

  MaterialReport({
    required this.type,
    required this.bundles,
    required this.tonnage,
  });
}

@HiveType(typeId: 7)
class Reinspection {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int totalBundles;

  @HiveField(2)
  final int reinspectedBundles;

  @HiveField(3)
  final int pendingBundles;

  @HiveField(4)
  final String? issue;

  @HiveField(5)
  final String? followUp;

  @HiveField(6)
  final String? remark;

  Reinspection({
    required this.name,
    required this.totalBundles,
    required this.reinspectedBundles,
    required this.pendingBundles,
    this.issue,
    this.followUp,
    this.remark,
  });
}

@HiveType(typeId: 8)
class ReportModel extends Report {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final DateTime date;

  @HiveField(2)
  @override
  final String shift;

  @HiveField(3)
  final PersonnelModel foreman;

  @HiveField(4)
  final PersonnelModel inspector1;

  @HiveField(5)
  final PersonnelModel inspector2;

  @HiveField(6)
  final PersonnelModel inspector3;

  @HiveField(7)
  final List<PersonnelModel>? overtimePersonnel;

  @HiveField(8)
  @override
  final SafetyTalkStatus safetyTalk;

  @HiveField(9)
  @override
  final EquipmentStatus measuringTools;

  @HiveField(10)
  @override
  final EquipmentStatus flashlight;

  @HiveField(11)
  @override
  final EquipmentStatus mobilePhone;

  @HiveField(12)
  @override
  final EquipmentStatus camera;

  @HiveField(13)
  @override
  final MaterialSection? usageDecision;

  @HiveField(14)
  @override
  final MaterialSection? shipmentHR;

  @HiveField(15)
  @override
  final MaterialSection? preDelivery;

  @HiveField(16)
  @override
  final List<Reinspection>? reinspections;

  @HiveField(17)
  @override
  final String? udIssue;

  @HiveField(18)
  @override
  final String? udFollowUp;

  @HiveField(19)
  @override
  final String? udRemark;

  @HiveField(20)
  @override
  final String createdBy;

  @HiveField(21)
  @override
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.date,
    required this.shift,
    required this.foreman,
    required this.inspector1,
    required this.inspector2,
    required this.inspector3,
    this.overtimePersonnel,
    required this.safetyTalk,
    required this.measuringTools,
    required this.flashlight,
    required this.mobilePhone,
    required this.camera,
    this.usageDecision,
    this.shipmentHR,
    this.preDelivery,
    this.reinspections,
    this.udIssue,
    this.udFollowUp,
    this.udRemark,
    required this.createdBy,
    required this.createdAt,
  }) : super(
          id: id,
          date: date,
          shift: shift,
          foreman: foreman,
          inspector1: inspector1,
          inspector2: inspector2,
          inspector3: inspector3,
          overtimePersonnel: overtimePersonnel,
          safetyTalk: safetyTalk,
          measuringTools: measuringTools,
          flashlight: flashlight,
          mobilePhone: mobilePhone,
          camera: camera,
          usageDecision: usageDecision,
          shipmentHR: shipmentHR,
          preDelivery: preDelivery,
          reinspections: reinspections,
          udIssue: udIssue,
          udFollowUp: udFollowUp,
          udRemark: udRemark,
          createdBy: createdBy,
          createdAt: createdAt,
        );

  factory ReportModel.fromReport(Report report) {
    return ReportModel(
      id: report.id,
      date: report.date,
      shift: report.shift,
      foreman: PersonnelModel.fromPersonnel(report.foreman),
      inspector1: PersonnelModel.fromPersonnel(report.inspector1),
      inspector2: PersonnelModel.fromPersonnel(report.inspector2),
      inspector3: PersonnelModel.fromPersonnel(report.inspector3),
      overtimePersonnel: report.overtimePersonnel
          ?.map((p) => PersonnelModel.fromPersonnel(p))
          .toList(),
      safetyTalk: report.safetyTalk,
      measuringTools: report.measuringTools,
      flashlight: report.flashlight,
      mobilePhone: report.mobilePhone,
      camera: report.camera,
      usageDecision: report.usageDecision,
      shipmentHR: report.shipmentHR,
      preDelivery: report.preDelivery,
      reinspections: report.reinspections,
      udIssue: report.udIssue,
      udFollowUp: report.udFollowUp,
      udRemark: report.udRemark,
      createdBy: report.createdBy,
      createdAt: report.createdAt,
    );
  }

  // Helper methods to convert enums to strings
  static String shiftTypeToString(ShiftType shift) {
    switch (shift) {
      case ShiftType.shift1:
        return 'Shift 1';
      case ShiftType.shift2:
        return 'Shift 2';
      case ShiftType.shift3:
        return 'Shift 3';
    }
  }

  static ShiftType stringToShiftType(String shift) {
    switch (shift) {
      case 'Shift 1':
        return ShiftType.shift1;
      case 'Shift 2':
        return ShiftType.shift2;
      case 'Shift 3':
        return ShiftType.shift3;
      default:
        return ShiftType.shift1;
    }
  }

  static String equipmentStatusToString(EquipmentStatus status) {
    switch (status) {
      case EquipmentStatus.ok:
        return 'OK';
      case EquipmentStatus.notOk:
        return 'Tidak OK';
    }
  }

  static EquipmentStatus stringToEquipmentStatus(String status) {
    switch (status) {
      case 'OK':
        return EquipmentStatus.ok;
      case 'Terkalibrasi':
        return EquipmentStatus.ok;
      case 'Tidak OK':
        return EquipmentStatus.notOk;
      default:
        return EquipmentStatus.ok;
    }
  }

  static String safetyTalkStatusToString(SafetyTalkStatus status) {
    switch (status) {
      case SafetyTalkStatus.conducted:
        return 'Dilaksanakan';
      case SafetyTalkStatus.notConducted:
        return 'Tidak dilaksanakan';
    }
  }

  static SafetyTalkStatus stringToSafetyTalkStatus(String status) {
    switch (status) {
      case 'Dilaksanakan':
        return SafetyTalkStatus.conducted;
      case 'Tidak dilaksanakan':
        return SafetyTalkStatus.notConducted;
      default:
        return SafetyTalkStatus.conducted;
    }
  }
}

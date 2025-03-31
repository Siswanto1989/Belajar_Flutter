import '../../data/models/report_model.dart';
import 'personnel.dart';

class MaterialSection {
  final List<MaterialReport> materials;
  
  MaterialSection({required this.materials});
  
  int get totalBundles {
    int total = 0;
    for (var material in materials) {
      total += material.bundles;
    }
    return total;
  }
  
  double get totalTonnage {
    double total = 0;
    for (var material in materials) {
      total += material.tonnage;
    }
    return total;
  }
}

class Report {
  final String id;
  final DateTime date;
  final String shift;
  final Personnel foreman;
  final Personnel inspector1;
  final Personnel inspector2;
  final Personnel inspector3;
  final List<Personnel>? overtimePersonnel;
  final SafetyTalkStatus safetyTalk;
  final EquipmentStatus measuringTools;
  final EquipmentStatus flashlight;
  final EquipmentStatus mobilePhone;
  final EquipmentStatus camera;
  final MaterialSection? usageDecision;
  final MaterialSection? shipmentHR;
  final MaterialSection? preDelivery;
  final List<Reinspection>? reinspections;
  final String? udIssue;
  final String? udFollowUp;
  final String? udRemark;
  final String createdBy;
  final DateTime createdAt;

  Report({
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
  });
  
  bool get hasReinspection => reinspections != null && reinspections!.isNotEmpty;
  
  bool get hasUDData => usageDecision != null && usageDecision!.materials.isNotEmpty;
  
  bool get hasShipmentData => shipmentHR != null && shipmentHR!.materials.isNotEmpty;
  
  bool get hasPreDeliveryData => preDelivery != null && preDelivery!.materials.isNotEmpty;
  
  int get totalReinspectionBundles {
    if (!hasReinspection) return 0;
    
    int total = 0;
    for (var reinspection in reinspections!) {
      total += reinspection.totalBundles;
    }
    return total;
  }
  
  int get totalReinspectedBundles {
    if (!hasReinspection) return 0;
    
    int total = 0;
    for (var reinspection in reinspections!) {
      total += reinspection.reinspectedBundles;
    }
    return total;
  }
  
  int get totalPendingReinspectionBundles {
    if (!hasReinspection) return 0;
    
    int total = 0;
    for (var reinspection in reinspections!) {
      total += reinspection.pendingBundles;
    }
    return total;
  }
}

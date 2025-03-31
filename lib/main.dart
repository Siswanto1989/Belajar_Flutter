import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'data/models/personnel_model.dart';
import 'data/models/report_model.dart';
import 'data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for local storage
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Register Hive adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(PersonnelModelAdapter());
  Hive.registerAdapter(ReportModelAdapter());
  Hive.registerAdapter(PersonnelStatusAdapter());
  Hive.registerAdapter(UserRoleAdapter());
  Hive.registerAdapter(ShiftTypeAdapter());
  Hive.registerAdapter(MaterialReportAdapter());
  Hive.registerAdapter(EquipmentStatusAdapter());
  Hive.registerAdapter(SafetyTalkStatusAdapter());
  Hive.registerAdapter(ReinspectionAdapter());
  
  // Open Hive boxes
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<PersonnelModel>('personnel');
  await Hive.openBox<ReportModel>('reports');
  await Hive.openBox('settings');
  
  // Initialize service locator (dependency injection)
  await setupServiceLocator();
  
  runApp(const QCFPReportApp());
}

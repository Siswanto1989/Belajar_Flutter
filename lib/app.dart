import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/routes.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/personnel/personnel_bloc.dart';
import 'presentation/bloc/report/report_bloc.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'presentation/screens/admin/personnel_management_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/role_selection_screen.dart';
import 'presentation/screens/common/home_screen.dart';
import 'presentation/screens/common/splash_screen.dart';
import 'presentation/screens/report/report_detail_screen.dart';
import 'presentation/screens/report/report_form_screen.dart';
import 'presentation/screens/report/reports_list_screen.dart';

class QCFPReportApp extends StatelessWidget {
  const QCFPReportApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => GetIt.I<AuthBloc>()..add(CheckAuthenticationEvent()),
        ),
        BlocProvider<PersonnelBloc>(
          create: (context) => GetIt.I<PersonnelBloc>()..add(LoadAllPersonnelEvent()),
        ),
        BlocProvider<ReportBloc>(
          create: (context) => GetIt.I<ReportBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'QCFP Report',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (context) => const SplashScreen(),
          Routes.roleSelection: (context) => const RoleSelectionScreen(),
          Routes.login: (context) => const LoginScreen(),
          Routes.home: (context) => const HomeScreen(),
          Routes.reportsList: (context) => const ReportsListScreen(),
          Routes.reportForm: (context) => const ReportFormScreen(),
          Routes.reportDetail: (context) => const ReportDetailScreen(),
          Routes.adminDashboard: (context) => const AdminDashboardScreen(),
          Routes.personnelManagement: (context) => const PersonnelManagementScreen(),
        },
      ),
    );
  }
}

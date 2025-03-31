import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/routes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/report/report_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load reports in background
    context.read<ReportBloc>().add(LoadAllReportsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QCFP Report App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.roleSelection,
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildHomeContent(state);
          }
          
          return const Center(
            child: Text('Not authenticated. Please login again.'),
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(Authenticated state) {
    final user = state.user;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(user.name, user.roleString),
          const SizedBox(height: 24.0),
          _buildActionsSection(user.isAdmin),
          const SizedBox(height: 24.0),
          _buildQuickStatsSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(String name, String role) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $name',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Role: $role',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16.0),
                const SizedBox(width: 8.0),
                Text(
                  'Today: ${Utils.formatDateForDisplay(DateTime.now())}',
                  style: const TextStyle(fontSize: 14.0),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Shift: ${Utils.getCurrentShift()}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Reports',
                Icons.description,
                Colors.blue,
                () => Navigator.pushNamed(context, Routes.reportsList),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildActionCard(
                'New Report',
                Icons.add_circle_outline,
                Colors.green,
                () => Navigator.pushNamed(context, Routes.reportForm),
              ),
            ),
          ],
        ),
        if (isAdmin) ...[
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Admin Panel',
                  Icons.admin_panel_settings,
                  Colors.purple,
                  () => Navigator.pushNamed(context, Routes.adminDashboard),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildActionCard(
                  'Personnel',
                  Icons.people,
                  Colors.orange,
                  () => Navigator.pushNamed(context, Routes.personnelManagement),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40.0,
                color: color,
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Statistics',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total Reports',
                            state.reports.length.toString(),
                            Icons.description,
                            Colors.blue,
                          ),
                          _buildStatItem(
                            'Last 7 Days',
                            _getReportsInLastDays(state.reports, 7).toString(),
                            Icons.date_range,
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Last Month',
                            _getReportsInLastDays(state.reports, 30).toString(),
                            Icons.calendar_month,
                            Colors.orange,
                          ),
                          _buildStatItem(
                            'Today',
                            _getReportsToday(state.reports).toString(),
                            Icons.today,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              AppButton(
                text: 'View All Reports',
                onPressed: () => Navigator.pushNamed(context, Routes.reportsList),
                icon: Icons.arrow_forward,
                isFullWidth: true,
                type: AppButtonType.outline,
              ),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28.0,
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  int _getReportsInLastDays(List<dynamic> reports, int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return reports.where((report) => report.date.isAfter(cutoffDate)).length;
  }

  int _getReportsToday(List<dynamic> reports) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return reports.where((report) {
      final reportDate = DateTime(report.date.year, report.date.month, report.date.day);
      return reportDate.isAtSameMomentAs(today);
    }).length;
  }
}

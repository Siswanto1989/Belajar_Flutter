import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../bloc/auth/auth_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administrator Control Panel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildAdminActions(),
            const SizedBox(height: 24),
            _buildReportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personnel Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Manage personnel information, including adding, removing, and reassigning personnel to different groups.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Manage Personnel',
              onPressed: () {
                Navigator.pushNamed(context, Routes.personnelManagement);
              },
              icon: Icons.people,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'View, create, and manage QCFP reports.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'View Reports',
              onPressed: () {
                Navigator.pushNamed(context, Routes.reportsList);
              },
              icon: Icons.description,
              isFullWidth: true,
            ),
            const SizedBox(height: 8),
            AppButton(
              text: 'Create New Report',
              onPressed: () {
                Navigator.pushNamed(context, Routes.reportForm);
              },
              icon: Icons.add_circle_outline,
              isFullWidth: true,
              type: AppButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

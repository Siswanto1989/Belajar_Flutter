import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40.0),
              _buildHeader(context),
              const SizedBox(height: 60.0),
              _buildRoleOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/icons/app_logo.svg',
          width: 120.0,
          height: 120.0,
        ),
        const SizedBox(height: 24.0),
        const Text(
          'QCFP Report',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        const Text(
          'Select your role to continue',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleOptions(BuildContext context) {
    return Column(
      children: [
        _buildRoleCard(
          context,
          title: 'Foreman',
          description: 'Create and manage reports',
          icon: Icons.engineering,
          onTap: () => _navigateToLogin(context, UserRole.foreman),
        ),
        const SizedBox(height: 16.0),
        _buildRoleCard(
          context,
          title: 'Inspector',
          description: 'View and contribute to reports',
          icon: Icons.search,
          onTap: () => _navigateToLogin(context, UserRole.inspector),
        ),
        const SizedBox(height: 16.0),
        _buildRoleCard(
          context,
          title: 'Admin',
          description: 'Manage personnel and all reports',
          icon: Icons.admin_panel_settings,
          onTap: () => _navigateToLogin(context, UserRole.admin),
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  icon,
                  size: 28.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, UserRole role) {
    Navigator.pushNamed(
      context,
      Routes.login,
      arguments: role,
    );
  }
}

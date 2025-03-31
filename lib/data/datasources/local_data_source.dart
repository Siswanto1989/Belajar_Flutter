import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/utils.dart';
import '../../domain/entities/user.dart';
import '../models/personnel_model.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';

abstract class LocalDataSource {
  // Auth
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<bool> loginUser(String pin, UserRole role);
  Future<void> logoutUser();
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunch(bool isFirst);
  Future<bool> verifyAdminPin(String pin);

  // Personnel
  Future<List<PersonnelModel>> getAllPersonnel();
  Future<List<PersonnelModel>> getPersonnelByGroup(String group);
  Future<void> addPersonnel(PersonnelModel personnel);
  Future<void> updatePersonnel(PersonnelModel personnel);
  Future<void> removePersonnel(String id);
  Future<void> movePersonnel(String personnelId, String newGroup, String newRole);
  Future<void> initializeDefaultPersonnel();

  // Reports
  Future<List<ReportModel>> getAllReports();
  Future<ReportModel?> getReportById(String id);
  Future<void> saveReport(ReportModel report);
  Future<void> deleteReport(String id);
  Future<String?> shareReportAsImage(BuildContext context, String reportId, GlobalKey reportKey);
  Future<String?> saveReportAsImage(GlobalKey reportKey, String reportId);
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box<UserModel> usersBox;
  final Box<PersonnelModel> personnelBox;
  final Box<ReportModel> reportsBox;
  final Box settingsBox;

  LocalDataSourceImpl({
    required this.usersBox,
    required this.personnelBox,
    required this.reportsBox,
    required this.settingsBox,
  }) {
    _initialize();
  }

  Future<void> _initialize() async {
    final isFirstLaunch = await this.isFirstLaunch();
    if (isFirstLaunch) {
      await initializeDefaultPersonnel();
      await setFirstLaunch(false);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userKey = settingsBox.get(AppConstants.currentUserKey);
      if (userKey != null) {
        return usersBox.get(userKey);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await usersBox.put(user.id, user);
      await settingsBox.put(AppConstants.currentUserKey, user.id);
    } catch (e) {
      debugPrint('Error saving user: $e');
      throw Exception('Failed to save user');
    }
  }

  @override
  Future<bool> loginUser(String pin, UserRole role) async {
    try {
      // For simplicity, we'll check if the user exists with the given pin
      // In a real app, you'd have proper authentication
      final users = usersBox.values.where((user) => user.pin == pin && user.role == role);
      
      if (users.isNotEmpty) {
        final user = users.first;
        await settingsBox.put(AppConstants.currentUserKey, user.id);
        return true;
      }
      
      // If no user exists with this PIN, create a new one
      final newUser = UserModel(
        id: Utils.generateUniqueId(),
        name: _getRoleDefaultName(role),
        pin: pin,
        role: role,
      );
      
      await usersBox.put(newUser.id, newUser);
      await settingsBox.put(AppConstants.currentUserKey, newUser.id);
      return true;
    } catch (e) {
      debugPrint('Error logging in user: $e');
      return false;
    }
  }

  String _getRoleDefaultName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.foreman:
        return 'Foreman';
      case UserRole.inspector:
        return 'Inspector';
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      await settingsBox.delete(AppConstants.currentUserKey);
    } catch (e) {
      debugPrint('Error logging out user: $e');
      throw Exception('Failed to logout user');
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      final isFirst = settingsBox.get(AppConstants.isFirstLaunchKey, defaultValue: true) as bool;
      return isFirst;
    } catch (e) {
      debugPrint('Error checking first launch: $e');
      return true;
    }
  }

  @override
  Future<void> setFirstLaunch(bool isFirst) async {
    try {
      await settingsBox.put(AppConstants.isFirstLaunchKey, isFirst);
    } catch (e) {
      debugPrint('Error setting first launch: $e');
      throw Exception('Failed to set first launch');
    }
  }

  @override
  Future<bool> verifyAdminPin(String pin) async {
    try {
      // Check against default admin PIN
      return pin == AppConstants.defaultAdminPin;
    } catch (e) {
      debugPrint('Error verifying admin PIN: $e');
      return false;
    }
  }

  // Personnel methods
  @override
  Future<List<PersonnelModel>> getAllPersonnel() async {
    try {
      return personnelBox.values.toList();
    } catch (e) {
      debugPrint('Error getting all personnel: $e');
      return [];
    }
  }

  @override
  Future<List<PersonnelModel>> getPersonnelByGroup(String group) async {
    try {
      return personnelBox.values.where((p) => p.group == group).toList();
    } catch (e) {
      debugPrint('Error getting personnel by group: $e');
      return [];
    }
  }

  @override
  Future<void> addPersonnel(PersonnelModel personnel) async {
    try {
      await personnelBox.put(personnel.id, personnel);
    } catch (e) {
      debugPrint('Error adding personnel: $e');
      throw Exception('Failed to add personnel');
    }
  }

  @override
  Future<void> updatePersonnel(PersonnelModel personnel) async {
    try {
      await personnelBox.put(personnel.id, personnel);
    } catch (e) {
      debugPrint('Error updating personnel: $e');
      throw Exception('Failed to update personnel');
    }
  }

  @override
  Future<void> removePersonnel(String id) async {
    try {
      await personnelBox.delete(id);
    } catch (e) {
      debugPrint('Error removing personnel: $e');
      throw Exception('Failed to remove personnel');
    }
  }

  @override
  Future<void> movePersonnel(String personnelId, String newGroup, String newRole) async {
    try {
      final personnel = personnelBox.get(personnelId);
      if (personnel != null) {
        final updatedPersonnel = personnel.copyWith(
          group: newGroup,
          role: newRole,
        );
        await personnelBox.put(personnelId, updatedPersonnel);
      }
    } catch (e) {
      debugPrint('Error moving personnel: $e');
      throw Exception('Failed to move personnel');
    }
  }

  @override
  Future<void> initializeDefaultPersonnel() async {
    try {
      // Clear existing personnel
      await personnelBox.clear();
      
      // Add default personnel groups
      // Group 1
      await _addDefaultPersonnel('Grup 1', 'Foreman', 'M. Albi Azhar');
      await _addDefaultPersonnel('Grup 1', 'Inspektor 1', 'Muhlas');
      await _addDefaultPersonnel('Grup 1', 'Inspektor 2', 'Sofyan');
      await _addDefaultPersonnel('Grup 1', 'Inspektor 3', 'Mercyanto');
      
      // Group 2
      await _addDefaultPersonnel('Grup 2', 'Foreman', 'Hartomi');
      await _addDefaultPersonnel('Grup 2', 'Inspektor 1', 'Ary Apreandy Me');
      await _addDefaultPersonnel('Grup 2', 'Inspektor 2', 'Sumartin');
      await _addDefaultPersonnel('Grup 2', 'Inspektor 3', 'Yunan K.');
      
      // Group 3
      await _addDefaultPersonnel('Grup 3', 'Foreman', 'Obay Baehaki');
      await _addDefaultPersonnel('Grup 3', 'Inspektor 1', 'Ary Sugiharto');
      await _addDefaultPersonnel('Grup 3', 'Inspektor 2', 'Irwan Agus S.');
      await _addDefaultPersonnel('Grup 3', 'Inspektor 3', 'Saefullah');
      
      // Group 4
      await _addDefaultPersonnel('Grup 4', 'Foreman', 'Asep Nuryadi');
      await _addDefaultPersonnel('Grup 4', 'Inspektor 1', 'Muslimin Abda\'u');
      await _addDefaultPersonnel('Grup 4', 'Inspektor 2', 'Umaedi');
      await _addDefaultPersonnel('Grup 4', 'Inspektor 3', 'Hasbullah');
    } catch (e) {
      debugPrint('Error initializing default personnel: $e');
      throw Exception('Failed to initialize default personnel');
    }
  }

  Future<void> _addDefaultPersonnel(String group, String role, String name) async {
    final personnel = PersonnelModel(
      id: Utils.generateUniqueId(),
      name: name,
      role: role,
      group: group,
      status: PersonnelStatus.present,
    );
    await personnelBox.put(personnel.id, personnel);
  }

  // Reports methods
  @override
  Future<List<ReportModel>> getAllReports() async {
    try {
      final reports = reportsBox.values.toList();
      reports.sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
      return reports;
    } catch (e) {
      debugPrint('Error getting all reports: $e');
      return [];
    }
  }

  @override
  Future<ReportModel?> getReportById(String id) async {
    try {
      return reportsBox.get(id);
    } catch (e) {
      debugPrint('Error getting report by ID: $e');
      return null;
    }
  }

  @override
  Future<void> saveReport(ReportModel report) async {
    try {
      await reportsBox.put(report.id, report);
    } catch (e) {
      debugPrint('Error saving report: $e');
      throw Exception('Failed to save report');
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      await reportsBox.delete(id);
    } catch (e) {
      debugPrint('Error deleting report: $e');
      throw Exception('Failed to delete report');
    }
  }

  @override
  Future<String?> shareReportAsImage(BuildContext context, String reportId, GlobalKey reportKey) async {
    try {
      final bytes = await Utils.widgetToImage(reportKey);
      if (bytes == null) return null;
      
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/report_$reportId.png';
      
      await Utils.shareViaWhatsApp(
        bytes,
        'QCFP Report - ${DateTime.now().toString().split(' ')[0]}',
      );
      
      return path;
    } catch (e) {
      debugPrint('Error sharing report as image: $e');
      return null;
    }
  }

  @override
  Future<String?> saveReportAsImage(GlobalKey reportKey, String reportId) async {
    try {
      final bytes = await Utils.widgetToImage(reportKey);
      if (bytes == null) return null;
      
      final path = await Utils.saveImageToGallery(
        bytes,
        'report_$reportId',
      );
      
      return path;
    } catch (e) {
      debugPrint('Error saving report as image: $e');
      return null;
    }
  }
}

import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final LocalDataSource localDataSource;

  ReportRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Report>> getAllReports() async {
    try {
      return await localDataSource.getAllReports();
    } catch (e) {
      throw Exception('Failed to get all reports');
    }
  }

  @override
  Future<Report?> getReportById(String id) async {
    try {
      return await localDataSource.getReportById(id);
    } catch (e) {
      throw Exception('Failed to get report by ID');
    }
  }

  @override
  Future<void> saveReport(Report report) async {
    try {
      await localDataSource.saveReport(
        ReportModel.fromReport(report),
      );
    } catch (e) {
      throw Exception('Failed to save report');
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      await localDataSource.deleteReport(id);
    } catch (e) {
      throw Exception('Failed to delete report');
    }
  }

  @override
  Future<String?> shareReportAsImage(BuildContext context, String reportId, GlobalKey reportKey) async {
    try {
      return await localDataSource.shareReportAsImage(context, reportId, reportKey);
    } catch (e) {
      throw Exception('Failed to share report as image');
    }
  }

  @override
  Future<String?> saveReportAsImage(GlobalKey reportKey, String reportId) async {
    try {
      return await localDataSource.saveReportAsImage(reportKey, reportId);
    } catch (e) {
      throw Exception('Failed to save report as image');
    }
  }
}

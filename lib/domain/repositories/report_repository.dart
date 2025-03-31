import 'package:flutter/material.dart';

import '../entities/report.dart';

abstract class ReportRepository {
  Future<List<Report>> getAllReports();
  Future<Report?> getReportById(String id);
  Future<void> saveReport(Report report);
  Future<void> deleteReport(String id);
  Future<String?> shareReportAsImage(BuildContext context, String reportId, GlobalKey reportKey);
  Future<String?> saveReportAsImage(GlobalKey reportKey, String reportId);
}

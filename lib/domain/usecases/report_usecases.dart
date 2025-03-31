import 'package:flutter/material.dart';

import '../entities/report.dart';
import '../repositories/report_repository.dart';

class ReportUseCases {
  final GetAllReports getAllReports;
  final GetReportById getReportById;
  final SaveReport saveReport;
  final DeleteReport deleteReport;
  final ShareReportAsImage shareReportAsImage;
  final SaveReportAsImage saveReportAsImage;

  ReportUseCases({
    required this.getAllReports,
    required this.getReportById,
    required this.saveReport,
    required this.deleteReport,
    required this.shareReportAsImage,
    required this.saveReportAsImage,
  });
}

class GetAllReports {
  final ReportRepository repository;

  GetAllReports(this.repository);

  Future<List<Report>> call() async {
    return await repository.getAllReports();
  }
}

class GetReportById {
  final ReportRepository repository;

  GetReportById(this.repository);

  Future<Report?> call(String id) async {
    return await repository.getReportById(id);
  }
}

class SaveReport {
  final ReportRepository repository;

  SaveReport(this.repository);

  Future<void> call(Report report) async {
    await repository.saveReport(report);
  }
}

class DeleteReport {
  final ReportRepository repository;

  DeleteReport(this.repository);

  Future<void> call(String id) async {
    await repository.deleteReport(id);
  }
}

class ShareReportAsImage {
  final ReportRepository repository;

  ShareReportAsImage(this.repository);

  Future<String?> call(BuildContext context, String reportId, GlobalKey reportKey) async {
    return await repository.shareReportAsImage(context, reportId, reportKey);
  }
}

class SaveReportAsImage {
  final ReportRepository repository;

  SaveReportAsImage(this.repository);

  Future<String?> call(GlobalKey reportKey, String reportId) async {
    return await repository.saveReportAsImage(reportKey, reportId);
  }
}

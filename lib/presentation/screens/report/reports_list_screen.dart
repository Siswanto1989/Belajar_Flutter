import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/report_card.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/report/report_bloc.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({Key? key}) : super(key: key);

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    context.read<ReportBloc>().add(LoadAllReportsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const LoadingWidget();
          } else if (state is ReportError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: _loadReports,
            );
          } else if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return _buildEmptyState();
            }
            
            return RefreshIndicator(
              onRefresh: () async => _loadReports(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
                itemCount: state.reports.length,
                itemBuilder: (context, index) {
                  final report = state.reports[index];
                  
                  return ReportCard(
                    report: report,
                    onTap: () => _openReportDetail(report.id),
                    onShare: () => _shareReport(report.id),
                    onDelete: _canDeleteReports() ? () => _deleteReport(report.id) : null,
                  );
                },
              ),
            );
          } else if (state is ReportDeleted) {
            // Report was deleted, reload the list
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadReports();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          }
          
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.reportForm),
        child: const Icon(Icons.add),
        tooltip: 'Create New Report',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 64.0,
            color: Colors.grey,
          ),
          const SizedBox(height: 16.0),
          const Text(
            'No Reports Found',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Create your first QCFP report',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24.0),
          AppButton(
            text: 'Create New Report',
            onPressed: () => Navigator.pushNamed(context, Routes.reportForm),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  void _openReportDetail(String reportId) {
    Navigator.pushNamed(
      context,
      Routes.reportDetail,
      arguments: reportId,
    );
  }

  void _shareReport(String reportId) {
    Navigator.pushNamed(
      context,
      Routes.reportDetail,
      arguments: reportId,
    ).then((_) {
      // After viewing details, make sure we have the latest share button
      final reportKey = GlobalKey();
      final reportBloc = context.read<ReportBloc>();
      
      if (reportBloc.state is ReportLoaded) {
        reportBloc.add(ShareReportAsImageEvent(
          context: context,
          reportId: reportId,
          reportKey: reportKey,
        ));
      }
    });
  }

  void _deleteReport(String reportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ReportBloc>().add(DeleteReportEvent(id: reportId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _canDeleteReports() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.isAdmin || authState.user.isForeman;
    }
    return false;
  }
}

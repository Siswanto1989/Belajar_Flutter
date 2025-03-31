import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/personnel_model.dart';
import '../../../data/models/report_model.dart';
import '../../../domain/entities/personnel.dart';
import '../../../domain/entities/report.dart';
import '../../bloc/report/report_bloc.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({Key? key}) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final GlobalKey _reportKey = GlobalKey();
  String? _reportId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _reportId = args;
        context.read<ReportBloc>().add(LoadReportByIdEvent(id: args));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          _buildShareButton(),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const LoadingWidget();
          } else if (state is ReportError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                if (_reportId != null) {
                  context.read<ReportBloc>().add(LoadReportByIdEvent(id: _reportId!));
                }
              },
            );
          } else if (state is ReportLoaded) {
            return _buildReportDetails(state.report);
          } else if (state is ReportShared) {
            // Show a snackbar after sharing
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report shared successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
            return _buildReportDetails(state.path != null && _reportId != null
                ? context.read<ReportBloc>().state is ReportLoaded
                    ? (context.read<ReportBloc>().state as ReportLoaded).report
                    : null
                : null);
          } else if (state is ReportImageSaved) {
            // Show a snackbar after saving
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report image saved to gallery!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
            return _buildReportDetails(state.path != null && _reportId != null
                ? context.read<ReportBloc>().state is ReportLoaded
                    ? (context.read<ReportBloc>().state as ReportLoaded).report
                    : null
                : null);
          }
          return const Center(
            child: Text('Select a report to view details'),
          );
        },
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildReportDetails(Report? report) {
    if (report == null) {
      return const Center(
        child: Text('Report not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: RepaintBoundary(
        key: _reportKey,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportHeader(report),
              const Divider(height: 32.0),
              _buildPersonnelSection(report),
              const Divider(height: 32.0),
              _buildEquipmentSection(report),
              if (report.hasUDData) ...[
                const Divider(height: 32.0),
                _buildUDSection(report),
              ],
              if (report.hasShipmentData) ...[
                const Divider(height: 32.0),
                _buildShipmentSection(report),
              ],
              if (report.hasPreDeliveryData) ...[
                const Divider(height: 32.0),
                _buildPreDeliverySection(report),
              ],
              if (report.hasReinspection) ...[
                const Divider(height: 32.0),
                _buildReinspectionSection(report),
              ],
              const SizedBox(height: 16.0),
              _buildFooter(report),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHeader(Report report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'QCFP REPORT',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date: ${Utils.formatDateForDisplay(report.date)}',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Shift: ${report.shift}',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          'Safety Talk: ${ReportModel.safetyTalkStatusToString(report.safetyTalk)}',
          style: const TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }

  Widget _buildPersonnelSection(Report report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personnel',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        _buildPersonnelRow('Foreman', report.foreman),
        _buildPersonnelRow('Inspector 1', report.inspector1),
        _buildPersonnelRow('Inspector 2', report.inspector2),
        _buildPersonnelRow('Inspector 3', report.inspector3),
        if (report.overtimePersonnel != null && report.overtimePersonnel!.isNotEmpty) ...[
          const SizedBox(height: 12.0),
          const Text(
            'Overtime Personnel:',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          ...report.overtimePersonnel!.map((p) => Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  '- ${p.name}',
                  style: const TextStyle(fontSize: 14.0),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildPersonnelRow(String role, Personnel personnel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              '$role:',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              personnel.name,
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
          if (personnel.status != PersonnelStatus.present)
            Text(
              personnel.statusString,
              style: TextStyle(
                fontSize: 14.0,
                color: personnel.status == PersonnelStatus.sick ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection(Report report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipment',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        _buildEquipmentRow(
          'Measuring Tools',
          ReportModel.equipmentStatusToString(report.measuringTools),
        ),
        _buildEquipmentRow(
          'Flashlight',
          ReportModel.equipmentStatusToString(report.flashlight),
        ),
        _buildEquipmentRow(
          'Mobile Phone',
          ReportModel.equipmentStatusToString(report.mobilePhone),
        ),
        _buildEquipmentRow(
          'Camera',
          ReportModel.equipmentStatusToString(report.camera),
        ),
      ],
    );
  }

  Widget _buildEquipmentRow(String name, String status) {
    final bool isOk = status == 'OK' || status == 'Terkalibrasi';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              '$name:',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 14.0,
              color: isOk ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUDSection(Report report) {
    final udSection = report.usageDecision!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Usage Decision (UD)',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        ...udSection.materials.map((material) => _buildMaterialRow(material)),
        const SizedBox(height: 8.0),
        Row(
          children: [
            const SizedBox(width: 120.0),
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 36.0),
            Text(
              '${udSection.totalBundles} bundles',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${Utils.formatNumber(udSection.totalTonnage)} tons',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (report.udIssue != null && report.udIssue!.isNotEmpty) ...[
          const SizedBox(height: 16.0),
          const Text(
            'Issues:',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            report.udIssue!,
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
        if (report.udFollowUp != null && report.udFollowUp!.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          const Text(
            'Follow-up:',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            report.udFollowUp!,
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
        if (report.udRemark != null && report.udRemark!.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          const Text(
            'Remarks:',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            report.udRemark!,
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
      ],
    );
  }

  Widget _buildShipmentSection(Report report) {
    final shipmentSection = report.shipmentHR!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipment HR',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        ...shipmentSection.materials.map((material) => _buildMaterialRow(material)),
        const SizedBox(height: 8.0),
        Row(
          children: [
            const SizedBox(width: 120.0),
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 36.0),
            Text(
              '${shipmentSection.totalBundles} bundles',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${Utils.formatNumber(shipmentSection.totalTonnage)} tons',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreDeliverySection(Report report) {
    final preDeliverySection = report.preDelivery!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pre-Delivery Inspection',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        ...preDeliverySection.materials.map((material) => _buildMaterialRow(material)),
        const SizedBox(height: 8.0),
        Row(
          children: [
            const SizedBox(width: 120.0),
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 36.0),
            Text(
              '${preDeliverySection.totalBundles} bundles',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${Utils.formatNumber(preDeliverySection.totalTonnage)} tons',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialRow(MaterialReport material) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              material.type,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 80.0,
            child: Text(
              '${material.bundles} bundles',
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
          const Spacer(),
          Text(
            '${Utils.formatNumber(material.tonnage)} tons',
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  Widget _buildReinspectionSection(Report report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reinspection',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        ...report.reinspections!.map((reinspection) => _buildReinspectionItem(reinspection)),
        const SizedBox(height: 8.0),
        Row(
          children: [
            const SizedBox(width: 120.0),
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 36.0),
            Text(
              '${report.totalReinspectionBundles} bundles',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 120.0),
            const Text(
              'Completed:',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 36.0),
            Text(
              '${report.totalReinspectedBundles} bundles',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const SizedBox(width: 120.0),
            const Text(
              'Pending:',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 36.0),
            Text(
              '${report.totalPendingReinspectionBundles} bundles',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: report.totalPendingReinspectionBundles > 0
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReinspectionItem(Reinspection reinspection) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reinspection.name,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              const SizedBox(width: 16.0),
              const SizedBox(
                width: 104.0,
                child: Text(
                  'Total Bundles:',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${reinspection.totalBundles}',
                style: const TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 16.0),
              const SizedBox(
                width: 104.0,
                child: Text(
                  'Reinspected:',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${reinspection.reinspectedBundles}',
                style: const TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 16.0),
              const SizedBox(
                width: 104.0,
                child: Text(
                  'Pending:',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${reinspection.pendingBundles}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: reinspection.pendingBundles > 0 ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
          if (reinspection.issue != null && reinspection.issue!.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16.0),
                const SizedBox(
                  width: 104.0,
                  child: Text(
                    'Issues:',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    reinspection.issue!,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ],
          if (reinspection.followUp != null && reinspection.followUp!.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16.0),
                const SizedBox(
                  width: 104.0,
                  child: Text(
                    'Follow-up:',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    reinspection.followUp!,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ],
          if (reinspection.remark != null && reinspection.remark!.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16.0),
                const SizedBox(
                  width: 104.0,
                  child: Text(
                    'Remarks:',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    reinspection.remark!,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(Report report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Created by: ${report.createdBy}',
          style: const TextStyle(
            fontSize: 14.0,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          'Date: ${Utils.formatDateForDisplay(report.createdAt)}',
          style: const TextStyle(
            fontSize: 14.0,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const SizedBox.shrink();
        }
        
        return IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            if (_reportId != null) {
              context.read<ReportBloc>().add(ShareReportAsImageEvent(
                    context: context,
                    reportId: _reportId!,
                    reportKey: _reportKey,
                  ));
            }
          },
          tooltip: 'Share Report',
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Save to Gallery',
              onPressed: () {
                if (_reportId != null) {
                  context.read<ReportBloc>().add(SaveReportAsImageEvent(
                        reportKey: _reportKey,
                        reportId: _reportId!,
                      ));
                }
              },
              icon: Icons.save_alt,
              type: AppButtonType.outline,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: AppButton(
              text: 'Share via WhatsApp',
              onPressed: () {
                if (_reportId != null) {
                  context.read<ReportBloc>().add(ShareReportAsImageEvent(
                        context: context,
                        reportId: _reportId!,
                        reportKey: _reportKey,
                      ));
                }
              },
              icon: Icons.share,
            ),
          ),
        ],
      ),
    );
  }
}

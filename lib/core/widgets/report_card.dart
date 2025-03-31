import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/report.dart';
import '../utils/utils.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const ReportCard({
    Key? key,
    required this.report,
    required this.onTap,
    this.onShare,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Utils.formatDateForDisplay(report.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    report.shift,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Foreman: ${report.foreman.name}',
                style: const TextStyle(
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Icon(Icons.storage, size: 16.0),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      _getSummary(),
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onShare != null)
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.green),
                      onPressed: onShare,
                      tooltip: 'Share',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSummary() {
    int totalBundles = 0;
    double totalTonnage = 0;

    // Add UD totals
    if (report.usageDecision != null) {
      for (var material in report.usageDecision!.materials) {
        totalBundles += material.bundles;
        totalTonnage += material.tonnage;
      }
    }

    // Add Shipment totals
    if (report.shipmentHR != null) {
      for (var material in report.shipmentHR!.materials) {
        totalBundles += material.bundles;
        totalTonnage += material.tonnage;
      }
    }

    // Add Pre-Delivery totals
    if (report.preDelivery != null) {
      for (var material in report.preDelivery!.materials) {
        totalBundles += material.bundles;
        totalTonnage += material.tonnage;
      }
    }

    return 'Total: $totalBundles bundles, ${Utils.formatNumber(totalTonnage)} ton';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  // Format date to dd-MM-yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  // Format date for display
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  // Generate a unique ID
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Format number with comma
  static String formatNumber(dynamic number) {
    if (number == null) return "0";
    if (number is String) {
      final parsedNumber = double.tryParse(number);
      if (parsedNumber == null) return "0";
      return NumberFormat("#,##0.##").format(parsedNumber);
    }
    return NumberFormat("#,##0.##").format(number);
  }

  // Parse a string to double, safely
  static double parseDouble(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value.replaceAll(',', '')) ?? 0;
  }

  // Convert a widget to image
  static Future<Uint8List?> widgetToImage(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error converting widget to image: $e');
      return null;
    }
  }

  // Save image to gallery
  static Future<String?> saveImageToGallery(Uint8List bytes, String name) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        return null;
      }
      
      // Save directly to gallery
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: name,
      );
      
      debugPrint('File saved to gallery: $result');
      
      return result['filePath'];
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  // Share image via WhatsApp
  static Future<void> shareViaWhatsApp(Uint8List bytes, String message) async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(bytes);

      await Share.shareFiles(
        [path],
        text: message,
      );
    } catch (e) {
      debugPrint('Error sharing via WhatsApp: $e');
    }
  }

  // Calculate total tonnage from bundle count and average weight
  static double calculateTonnage(double bundles, double avgWeight) {
    return bundles * avgWeight;
  }

  // Show a snackbar
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show a loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  // Get the current shift based on time
  static String getCurrentShift() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14) {
      return 'Shift 1';
    } else if (hour >= 14 && hour < 22) {
      return 'Shift 2';
    } else {
      return 'Shift 3';
    }
  }
}

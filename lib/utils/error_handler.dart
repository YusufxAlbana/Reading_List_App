import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorHandler {
  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    debugPrint('Error occurred: $error');
    debugPrint('Stack trace: $stackTrace');

    Get.snackbar(
      'Error',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
}

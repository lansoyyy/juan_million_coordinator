import 'package:flutter/material.dart';

import 'package:get/get.dart';

showToast(msg) {
  final message = msg.toString();
  final lower = message.toLowerCase();
  final isError = lower.contains('failed') ||
      lower.contains('invalid') ||
      lower.contains('not enough') ||
      lower.contains('error') ||
      lower.contains('cannot');

  Get.rawSnackbar(
    message: message,
    backgroundColor: isError ? Colors.red : const Color(0xFF4CAF50),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    duration: const Duration(seconds: 2),
  );
}

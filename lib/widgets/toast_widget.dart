import 'package:flutter/material.dart';

import 'package:get/get.dart';

showToast(msg) {
  final message = msg.toString();
  final lower = message.toLowerCase();
  final isError = lower.contains('failed') ||
      lower.contains('invalid') ||
      lower.contains('not enough') ||
      lower.contains('error') ||
      lower.contains('cannot') ||
      lower.contains('please') ||
      lower.contains('wrong') ||
      lower.contains('does not exist') ||
      lower.contains('not found');

  Get.rawSnackbar(
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white),
    ),
    icon: Icon(
      isError ? Icons.error_outline : Icons.check_circle_outline,
      color: Colors.white,
    ),
    backgroundColor: isError ? Colors.red : const Color(0xFF4CAF50),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    duration: const Duration(seconds: 2),
  );
}

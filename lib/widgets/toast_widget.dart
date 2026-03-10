import 'package:flutter/material.dart';

import 'package:get/get.dart';

enum ToastType { success, error, info }

showToast(msg, {ToastType type = ToastType.info}) {
  final message = msg.toString();
  final bool isError = type == ToastType.error;
  final bool isSuccess = type == ToastType.success;

  Get.rawSnackbar(
    messageText: Text(message, style: const TextStyle(color: Colors.white)),
    icon: Icon(
      isError
          ? Icons.error_outline
          : isSuccess
          ? Icons.check_circle_outline
          : Icons.info_outline,
      color: Colors.white,
    ),
    backgroundColor: isError
        ? const Color(0xFFC62828)
        : isSuccess
        ? const Color(0xFF2E7D32)
        : const Color(0xFF1565C0),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    duration: const Duration(seconds: 2),
  );
}

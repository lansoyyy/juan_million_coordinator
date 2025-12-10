import 'package:flutter/material.dart';

import 'package:get/get.dart';

showToast(msg) {
  Get.showSnackbar(GetSnackBar(
    message: msg,
    backgroundColor: const Color(0xFF4CAF50),
    duration: const Duration(seconds: 2),
  ));
}

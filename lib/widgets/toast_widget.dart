import 'package:flutter/material.dart';

import 'package:get/get.dart';


 showToast(msg) {


  Get.showSnackbar(GetSnackBar(
   message:  msg,
   backgroundColor: Colors.red,
  
   duration: const Duration(seconds: 2),
 ));
}

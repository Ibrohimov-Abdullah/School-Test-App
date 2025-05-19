import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.onInit();
  }

  _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.any(
      (element) => element == ConnectivityResult.none,
    )) {
      Get.rawSnackbar(
          backgroundColor: Colors.red,
          messageText: Row(
            children: [
              10.horizontalSpace,
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
              ),
              20.horizontalSpace,
              Text(
                "Iltimos internetni yoqing!",
                style: TextStyle(),
                ),
            ],
          ),
          duration: const Duration(days: 1));
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final PageController pageController = PageController();

  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final isEmailSent = false.obs;

  Future<void> sendPasswordResetEmail() async {
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      Get.snackbar(
        'Xatolik',
        'Iltimos, to\'g\'ri elektron pochta kiriting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      isEmailSent.value = true;
      Get.snackbar(
        'Muvaffaqiyatli',
        'Parolni tiklash havolasi elektron pochtangizga yuborildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Xatolik yuz berdi';
      if (e.code == 'user-not-found') {
        errorMessage = 'Bunday elektron pochta manzili topilmadi';
      }
      Get.snackbar(
        'Xatolik',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Xatolik yuz berdi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goBackToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_test_app/core/storage/app_storage.dart';
import 'package:school_test_app/features/admin/view/pages/admin_dashboard.dart';
import 'package:school_test_app/features/auth/view/pages/register_page.dart';
import '../../main/view/pages/main_page.dart';
import '../../main/view/pages/pyschologist_dashboard_page.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    if (emailController.text == "admin@gmail.com" && passwordController.text == "Abdulaziz2025000") {
      isLoading.value = false;
      Get.offAll(AdminDashboardScreen());
    } else {
      try {
        // 1. Sign in with email and password
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // 2. Check if email is verified
        if (!userCredential.user!.emailVerified) {
          Get.snackbar(
            'Tasdiqlash kerak',
            'Iltimos, elektron pochtangizni tasdiqlang',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }

        // 3. Get user role from Firestore
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        final role = userDoc['role'] as String;
        final isVerified = userDoc['isVerified'] as bool? ?? false;

        // 4. Additional verification check
        if (!isVerified) {
          Get.snackbar(
            'Tasdiqlash kerak',
            'Administrator tomonidan tasdiqlanishi kerak',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }

        // 5. Navigate based on role
        await AppStorage.storeBool(key: StorageKey.isUserHave, value: true);
        emailController.clear();
        passwordController.clear();
        switch (role) {
          case 'psychologist':
            Get.offAll(() => PsychologistDashboardScreen());
            break;
          case 'student':
            Get.offAll(() => MainPage());
            break;
          default:
            Get.offAll(() => MainPage());
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Bunday foydalanuvchi topilmadi';
            break;
          case 'wrong-password':
            errorMessage = 'Noto\'g\'ri parol';
            break;
          case 'invalid-email':
            errorMessage = 'Noto\'g\'ri elektron pochta formati';
            break;
          case 'user-disabled':
            errorMessage = 'Ushbu hisob o\'chirilgan';
            break;
          default:
            errorMessage = 'Kirishda xatolik yuz berdi';
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
          'Kirishda xatolik yuz berdi: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Xatolik',
        'Iltimos, elektron pochtangizni kiriting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      Get.snackbar(
        'Muvaffaqiyatli',
        'Parolni tiklash havolasi elektron pochtangizga yuborildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
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

  void goToRegister() {
    Get.to(() => RegistrationScreen());
  }

  @override
  void onClose() {
    emailController.text = "";
    passwordController.text = "";
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/core/constants/constants.dart';
import 'package:school_test_app/features/auth/controllers/login_controller.dart';
import '../../../themes/app_colors.dart';
import 'forget_password_page.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final LoginController _controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and app name
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.customOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 120.w),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 40.w,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Aqlli So\'rovnoma',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Xush kelibsiz! Davom etish uchun tizimga kiring',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Email field
                  TextFormField(
                    style: TextStyle(color: Colors.black),
                    controller: _controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Elektron pochta',
                      hintText: 'Elektron pochtangizni kiriting',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Iltimos, elektron pochtangizni kiriting';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'To\'g\'ri elektron pochta kiriting';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Password field
                  Obx(() => TextFormField(
                    style: TextStyle(color: Colors.black),
                    controller: _controller.passwordController,
                    obscureText: _controller.obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Parol',
                      hintText: 'Parolingizni kiriting',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _controller.obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: _controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Iltimos, parolingizni kiriting';
                      }
                      if (value.length < 6) {
                        return 'Parol kamida 6 belgidan iborat bo\'lishi kerak';
                      }
                      return null;
                    },
                  )),
                  SizedBox(height: 8.h),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: Text('Parolni tiklash'),
                            content: Text('Parolni tiklash havolasi ushbu elektron pochta manziliga yuboriladi'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text('Bekor qilish'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  _controller.resetPassword();
                                },
                                child: Text('Yuborish'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => ForgotPasswordPage());
                        },
                        child: Text('Parolni unutdingizmi?'.tr),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Login button
                  Obx(() => ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : _controller.login,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: AppColors.primary,
                    ),
                    child: _controller.isLoading.value
                        ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Kirish',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )),
                  SizedBox(height: 24.h),

                  // Register option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hisobingiz yo'qmi? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textGrey,
                        ),
                      ),
                      TextButton(
                        onPressed: _controller.goToRegister,
                        child: Text(
                          'Ro\'yxatdan o\'tish',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/core/constants/constants.dart';

import '../../../themes/app_colors.dart';
import '../../controllers/forget_password_controller.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  final ForgotPasswordController _controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parolni tiklash'.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _controller.goBackToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Obx(() {
            if (_controller.isEmailSent.value) {
              return _buildSuccessUI();
            } else {
              return _buildFormUI();
            }
          }),
        ),
      ),
    );
  }

  Widget _buildFormUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 40.h),
        // Illustration
        Container(
          width: 150.w,
          height: 150.w,
          decoration: BoxDecoration(
            color: AppColors.primary.customOpacity(0.1),
            borderRadius: BorderRadius.circular(80.r),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 60.w,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          'Parolni tiklash'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Parolingizni tiklash uchun elektron pochtangizga havola yuboramiz'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textGrey,
          ),
        ),
        SizedBox(height: 40.h),
        // Email field
        TextFormField(
          controller: _controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Elektron pochta'.tr,
            hintText: 'Elektron pochtangizni kiriting'.tr,
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Iltimos, elektron pochtangizni kiriting'.tr;
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'To\'g\'ri elektron pochta kiriting'.tr;
            }
            return null;
          },
        ),
        SizedBox(height: 24.h),
        // Submit button
        Obx(() => ElevatedButton(
          onPressed: _controller.isLoading.value
              ? null
              : _controller.sendPasswordResetEmail,
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
            'Havolani yuborish'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )),
        SizedBox(height: 16.h),
        // Back to login
        TextButton(
          onPressed: _controller.goBackToLogin,
          child: Text(
            'Kirish sahifasiga qaytish'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 40.h),
        // Success illustration
        Container(
          width: 150.w,
          height: 150.w,
          decoration: BoxDecoration(
            color: Colors.green.customOpacity(0.1),
            borderRadius: BorderRadius.circular(80.r),
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 60.w,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          'Havola yuborildi!'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Parolni tiklash havolasi ${_controller.emailController.text} manziliga yuborildi. '
              'Elektron pochtangizni tekshiring va havolaga bosing.'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textGrey,
          ),
        ),
        SizedBox(height: 40.h),
        // Back to login button
        ElevatedButton(
          onPressed: _controller.goBackToLogin,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: AppColors.primary,
          ),
          child: Text(
            'Kirish sahifasiga qaytish'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
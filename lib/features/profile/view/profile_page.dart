import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/core/constants/constants.dart';

import '../../themes/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 24.sp),
            onPressed: () => controller.logout(context),
            tooltip: 'Chiqish',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildProfileHeader(),
              SizedBox(height: 24.h),
              _buildUserInfoCard(context),
              SizedBox(height: 24.h),
              _buildVerificationStatus(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Obx(() => GestureDetector(
          onTap: () => controller.pickImage(),
          child: CircleAvatar(
            radius: 60.r,
            backgroundColor: AppColors.primary.customOpacity(0.1),
            backgroundImage: controller.profileImagePath.value.isNotEmpty
                ? FileImage(File(controller.profileImagePath.value)) as ImageProvider
                : const AssetImage('assets/images/default_profile.png'),
            child: controller.profileImagePath.value.isEmpty
                ? Icon(Icons.camera_alt, size: 30.sp, color: AppColors.primary)
                : null,
          ),
        )),
        SizedBox(height: 16.h),
        Obx(() => Text(
          controller.name.value,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        )),
        SizedBox(height: 4.h),
        Obx(() => Text(
          controller.role.value == 'student'
              ? 'Oʻquvchi'
              : controller.role.value == 'teacher'
              ? 'Psixolog'
              : '',
          style: TextStyle(fontSize: 16.sp, color: AppColors.textGrey),
        )),
      ],
    );
  }

  void _showTopUpDialog(BuildContext context) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Balansni to\'ldirish'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Summa (so\'m)',
            hintText: '2000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              final amount = int.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                Get.back();
                await controller.topUpBalance(amount, context);
              } else {
                Get.snackbar('Xatolik', 'Noto\'g\'ri summa kiritildi');
              }
            },
            child: Text('To\'ldirish'),
          ),
        ],
      ),
    );
  }
  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildInfoRow('Elektron pochta', controller.email.value, Icons.email),
            Divider(height: 24.h, thickness: 1),
            _buildInfoRow('Maktab', controller.school.value, Icons.school),
            Divider(height: 24.h, thickness: 1),
            _buildInfoRow('Tuman/Shahar', controller.district.value, Icons.location_on),
            if (controller.role.value == 'student') ...[
              Divider(height: 24.h, thickness: 1),
              _buildInfoRow('Sinf', controller.grade.value, Icons.class_),
            ],
            Divider(height: 24.h, thickness: 1),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Icon(Icons.add, size: 24.sp, color: AppColors.primary),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showTopUpDialog(context),
                      child: Text('Balansni to\'ldirish'),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.primary),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus() {
    return Obx(() => Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: controller.isVerified.value
            ? AppColors.success.customOpacity(0.1)
            : AppColors.error.customOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(
            controller.isVerified.value ? Icons.verified : Icons.warning,
            size: 32.sp,
            color: controller.isVerified.value ? AppColors.success : AppColors.error,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              controller.isVerified.value
                  ? 'Hisobingiz tasdiqlangan'
                  : 'Hisobingiz tasdiqlanmagan',
              style: TextStyle(
                fontSize: 16.sp,
                color: controller.isVerified.value ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/core/constants/constants.dart';

import '../../themes/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {

  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = Get.put(ProfileController());

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
    Get.to(PaymentPage());
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



class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ProfileController _controller = Get.find<ProfileController>();
  final List<int> predefinedAmounts = [10000, 20000, 50000, 100000];
  int? selectedAmount;
  final TextEditingController _customAmountController = TextEditingController();
  Timer? _paymentCheckTimer;
  bool _paymentInProgress = false;

  @override
  void dispose() {
    _paymentCheckTimer?.cancel();
    _customAmountController.dispose();
    super.dispose();
  }

  void _startPaymentCheck(int amount) {
    // Start periodic payment check
    _paymentCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_paymentInProgress) {
        return;
      }

      _controller.checkPaymentStatus(amount, context).then((isPaid) {
        if (isPaid) {
          _paymentInProgress = false;
          timer.cancel();
          // Payment successful, return to profile
          Future.delayed(const Duration(seconds: 2), () {
            Get.back();
          });
        }
      });
    });
  }

  void _processPayment(int amount) {
    setState(() {
      _paymentInProgress = true;
    });

    _controller.startTopUp(amount, context).then((success) {
      if (success) {
        _startPaymentCheck(amount);
      } else {
        setState(() {
          _paymentInProgress = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balansni to\'ldirish', style: TextStyle(fontSize: 20.sp)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(),
                SizedBox(height: 24.h),
                _buildAmountSelection(),
                SizedBox(height: 30.h),
                _buildPaymentButton(),
                if (_paymentInProgress) _buildPaymentStatusIndicator(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _controller.name.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _controller.email.value,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Joriy balans',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  '${_controller.balance.value} so\'m',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To\'ldirish miqdorini tanlang',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: predefinedAmounts.map((amount) {
            final bool isSelected = selectedAmount == amount;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAmount = amount;
                  _customAmountController.clear();
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 2 - 26.w,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${amount.toString()} so\'m',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24.h),
        Text(
          'Yoki boshqa miqdor kiriting',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _customAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Miqdorni kiriting',
            suffixText: 'so\'m',
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                selectedAmount = int.tryParse(value);
              });
            } else {
              setState(() {
                selectedAmount = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: (selectedAmount != null && selectedAmount! > 0 && !_paymentInProgress)
            ? () => _processPayment(selectedAmount!)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        child: Text(
          'To\'lovni boshlash',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusIndicator() {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'To\'lov holati tekshirilmoqda...\nIltimos, Click ilovasi orqali to\'lovni yakunlang.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

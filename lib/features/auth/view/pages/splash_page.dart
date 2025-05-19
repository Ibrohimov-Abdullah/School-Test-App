import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/core/constants/constants.dart';
import 'package:school_test_app/core/storage/app_storage.dart';

import '../../../main/view/pages/main_page.dart';
import '../../../themes/app_colors.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _controller.forward();
    checkForLogin();
  }

  checkForLogin() async {
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        bool? isLoggedIn = await AppStorage.loadBool(key: StorageKey.isUserHave);
        if (isLoggedIn != null) {
          Get.offAll(MainPage());
        } else {
          Get.offAll(LoginScreen());
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.customOpacity(0.8),
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  // Logo or icon
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 60.w,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // App name
                  Text(
                    'Smart Survey',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Tagline
                  Text(
                    'Efficient school surveys made simple',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.customOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80.h),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3.w,
            ),
          ],
        ),
      ),
    );
  }
}

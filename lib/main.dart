import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_test_app/config/app_lock_wraper.dart';

import 'config/dependency_injection.dart';
import 'features/auth/view/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  DependencyInjection.init();
  runApp(const SchoolTestApp());
}

class SchoolTestApp extends StatelessWidget {
  const SchoolTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Quiz App',
        home: AppLockWrapper(
          child: const SplashScreen(),
        ),
      ),
    );
  }
}

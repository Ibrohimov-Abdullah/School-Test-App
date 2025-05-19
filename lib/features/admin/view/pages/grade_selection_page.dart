import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'class_selection_page.dart';

class GradeSelectionScreen extends StatelessWidget {
  final String district;
  final String school;

  GradeSelectionScreen({required this.district, required this.school});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Grade at $school')),
      body: GridView.count(
        padding: EdgeInsets.all(16.w),
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        children: List.generate(11, (index) {
          final grade = index + 1;
          return Card(
            child: InkWell(
              onTap: () => Get.to(() => ClassSelectionScreen(
                district: district,
                school: school,
                grade: grade,
              )),
              child: Center(
                child: Text(
                  'Grade $grade',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
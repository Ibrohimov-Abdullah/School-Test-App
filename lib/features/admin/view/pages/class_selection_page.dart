import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/features/admin/view/pages/student_list_page.dart';

class ClassSelectionScreen extends StatelessWidget {
  final String district;
  final String school;
  final int grade;

  ClassSelectionScreen({
    required this.district,
    required this.school,
    required this.grade,
  });

  final _classes = ['A', 'B', 'C', 'D']; // Example classes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Class in Grade $grade')),
      body: GridView.count(
        padding: EdgeInsets.all(16.w),
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        children: _classes
            .map((classLetter) => Card(
          child: InkWell(
            onTap: () => Get.to(() => StudentListScreen(
              district: district,
              school: school,
              grade: grade,
              classLetter: classLetter,
            )),
            child: Center(
              child: Text(
                'Class $classLetter',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/features/admin/view/pages/school_selection_page.dart';

class DistrictSelectionScreen extends StatelessWidget {
  final _districts = [
    'Andijon shahar',
    'Asaka',
    'Xonobod',
    // Add all your districts here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select District')),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _districts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_districts[index]),
              onTap: () => Get.to(() => SchoolSelectionScreen(district: _districts[index])),
            ),
          );
        },
      ),
    );
  }
}
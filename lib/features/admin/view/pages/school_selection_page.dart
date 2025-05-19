import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'grade_selection_page.dart';

class SchoolSelectionScreen extends StatelessWidget {
  final String district;

  SchoolSelectionScreen({required this.district});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select School in $district')),
      body: FutureBuilder<List<String>>(
        future: _fetchSchools(district),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading schools'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(snapshot.data![index]),
                  onTap: () => Get.to(() => GradeSelectionScreen(
                    district: district,
                    school: snapshot.data![index],
                  )),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _fetchSchools(String district) async {
    // Implement Firebase query to get schools in the district
    return [
      '31-maktab',
      '45-maktab',
      // Sample data - replace with actual Firestore query
    ];
  }
}
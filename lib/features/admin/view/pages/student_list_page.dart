import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/features/admin/view/pages/students_result_page.dart';

class StudentListScreen extends StatelessWidget {
  final String district;
  final String school;
  final int grade;
  final String classLetter;

  StudentListScreen({
    required this.district,
    required this.school,
    required this.grade,
    required this.classLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students in Grade $grade $classLetter'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading students'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final student = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(student['name']),
                  subtitle: Text(student['id']),
                  trailing: IconButton(
                    icon: Icon(Icons.analytics),
                    onPressed: () => Scaffold(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    // Implement Firebase query to get students in this class
    return [
      {'id': '1', 'name': 'Student One'},
      {'id': '2', 'name': 'Student Two'},
      // Sample data - replace with actual Firestore query
    ];
  }

  void _exportToExcel() {
    // Implement Excel export functionality
    Get.snackbar('Success', 'Data exported to Excel');
  }
}
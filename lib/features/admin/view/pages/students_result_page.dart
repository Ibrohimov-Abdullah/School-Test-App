import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TestResultsScreen extends StatelessWidget {
  const TestResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Natijalari'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Filters
            _buildFilters(),
            SizedBox(height: 16.h),
            // Results table
            Expanded(
              child: _buildResultsTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('tests').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Test',
                            border: OutlineInputBorder(),
                          ),
                          items: const [],
                          onChanged: (value) {},
                        );
                      }
                      final tests = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Test',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('Barcha')),
                          ...tests.map((test) => DropdownMenuItem(
                            value: test.id,
                            child: Text(test['title'] ?? 'Noma\'lum test'),
                          ),).toList(),
                        ],
                        onChanged: (value) {

                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Foydalanuvchi turi',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Barchasi')),
                      DropdownMenuItem(value: 'student', child: Text('O\'quvchi')),
                      DropdownMenuItem(value: 'teacher', child: Text('O\'qituvchi')),
                      DropdownMenuItem(value: 'umumiy', child: Text('Umumiy')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('districts').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tuman',
                            border: OutlineInputBorder(),
                          ),
                          items: const [],
                          onChanged: (value) {},
                        );
                      }
                      final districts = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Tuman',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('Barcha tumanlar')),
                          ...districts.map((district) => DropdownMenuItem(
                            value: district.id,
                            child: Text(district['name'] ?? 'Noma\'lum tuman'),
                          )).toList(),
                        ],
                        onChanged: (value) {},
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('schools').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Maktab',
                            border: OutlineInputBorder(),
                          ),
                          items: const [],
                          onChanged: (value) {},
                        );
                      }
                      final schools = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Maktab',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('Barcha maktablar')),
                          ...schools.map((school) => DropdownMenuItem(
                            value: school.id,
                            child: Text(school['name'] ?? 'Noma\'lum maktab'),
                          )).toList(),
                        ],
                        onChanged: (value) {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('user_test_results').snapshots(),
      builder: (context, resultsSnapshot) {
        if (resultsSnapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${resultsSnapshot.error}'));
        }

        if (resultsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = resultsSnapshot.data!.docs;

        if (results.isEmpty) {
          return const Center(child: Text('Hech qanday natija topilmadi'));
        }

        final futures = results.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;
          final userRef = data['userId']?.toString() ?? '';
          final testRef = data['testId']?.toString() ?? '';

          try {
            final userDoc = await FirebaseFirestore.instance.doc('users/$userRef').get();
            final testDoc = await FirebaseFirestore.instance.doc('tests/$testRef').get();

            return {
              'data': data,
              'userData': userDoc.data(),
              'testData': testDoc.data(),
            };
          } catch (e) {
            return {
              'data': data,
              'userData': null,
              'testData': null,
            };
          }
        }).toList();

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(futures),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (asyncSnapshot.hasError) {
              return Center(child: Text('Ma\'lumotlarni yuklashda xatolik: ${asyncSnapshot.error}'));
            }

            final combinedData = asyncSnapshot.data!;

            return Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('№')),
                    DataColumn(label: Text('F.I.Sh')),
                    DataColumn(label: Text('Roli')),
                    DataColumn(label: Text('Maktab')),
                    DataColumn(label: Text('Test nomi')),
                    DataColumn(label: Text('To\'g\'ri javoblar')),
                    DataColumn(label: Text('Foiz')),
                    DataColumn(label: Text('Vaqti')),
                  ],
                  rows: combinedData.map((item) {
                    final data = item['data'] as Map<String, dynamic>;
                    final userData = item['userData'] as Map<String, dynamic>?;
                    final testData = item['testData'] as Map<String, dynamic>?;

                    final totalQuestions = data['totalQuestions'] ?? 1;
                    final correctAnswers = data['correctAnswers'] ?? 0;
                    final score = totalQuestions > 0
                        ? (correctAnswers / totalQuestions * 100).toStringAsFixed(1)
                        : '0.0';

                    return DataRow(
                      cells: [
                        DataCell(Text('${combinedData.indexOf(item) + 1}')),
                        DataCell(Text(userData?['name']?.toString() ?? 'Noma\'lum')),
                        DataCell(Text(_getRoleName(userData?['role']?.toString() ?? ''))),
                        DataCell(Text(userData?['school']?.toString() ?? 'Noma\'lum')),
                        DataCell(Text(testData?['title']?.toString() ?? 'Noma\'lum test')),
                        DataCell(Text('$correctAnswers/$totalQuestions')),
                        DataCell(Text('$score%')),
                        DataCell(Text(_formatDate(data['submittedAt']))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'student': return 'O\'quvchi';
      case 'teacher': return 'O\'qituvchi';
      case 'umumiy': return 'Umumiy';
      default: return role;
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return timestamp?.toString() ?? 'Noma\'lum';
    } catch (e) {
      return 'Noma\'lum';
    }
  }
}
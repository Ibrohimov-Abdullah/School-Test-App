import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/features/admin/view/pages/location_page.dart';
import 'package:school_test_app/features/admin/view/pages/students_result_page.dart';
import 'package:school_test_app/features/auth/view/pages/login_page.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [IconButton(onPressed: () => Get.offAll(LoginScreen()), icon: Icon(Icons.logout))],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tumanlar',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildDistrictsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              Get.to(() => const CreateTestScreen());
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16.h),
          FloatingActionButton(
            onPressed: () {
              Get.to(() => const LocationManagementScreen());
            },
            child: Icon(Icons.location_city),
          ),
          SizedBox(height: 16.h),
          FloatingActionButton(
            onPressed: () {
              Get.to(() => const TestResultsScreen());
            },
            child: Icon(Icons.assessment),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('districts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final districts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: districts.length,
          itemBuilder: (context, index) {
            final district = districts[index];
            return Card(
              child: ListTile(
                title: Text(district['name']),
                subtitle: Text(district['region']),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Get.to(() => SchoolsScreen(districtId: district.id));
                },
              ),
            );
          },
        );
      },
    );
  }
}

class CreateTestScreen extends StatefulWidget {
  const CreateTestScreen({Key? key}) : super(key: key);

  @override
  _CreateTestScreenState createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _targetGrade = '10-sinf';
  final List<Map<String, dynamic>> _questions = []; // Changed to store question data as maps

  final List<String> _gradeOptions = [
    '10-sinf',
    '11-sinf',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yangi test yaratish'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Test nomi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, test nomini kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Test tavsifi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, test tavsifini kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _targetGrade,
                decoration: const InputDecoration(
                  labelText: 'Test qilinadigan sinf',
                  border: OutlineInputBorder(),
                ),
                items: _gradeOptions.map(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _targetGrade = newValue!;
                  });
                },
              ),
              SizedBox(height: 24.h),
              Text(
                'Savollar',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              ..._buildQuestionList(),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _addQuestion,
                child: const Text('Savol qo\'shish'),
              ),
              SizedBox(height: 32.h),
              Center(
                child: ElevatedButton(
                  onPressed: _submitTest,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  ),
                  child: const Text('Testni saqlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuestionList() {
    return List<Widget>.generate(_questions.length, (index) {
      final question = _questions[index];
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${index + 1}. ${question['text']}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeQuestion(index),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ..._buildOptionsList(question['options']),
              SizedBox(height: 8.h),
              Text(
                'To\'g\'ri javob: ${question['options'][question['correctIndex']]}',
                style: TextStyle(fontSize: 14.sp, color: Colors.green),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildOptionsList(List<String> options) {
    return List<Widget>.generate(options.length, (optionIndex) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Text('${String.fromCharCode(65 + optionIndex)}. '),
            Expanded(child: Text(options[optionIndex])),
          ],
        ),
      );
    });
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => AddQuestionDialog(
        onSave: (question, options, correctIndex) {
          setState(
            () {
              _questions.add(
                {
                  'text': question,
                  'options': options,
                  'correctIndex': correctIndex,
                },
              );
            },
          );
        },
      ),
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _submitTest() async {
    if (_formKey.currentState!.validate()) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Iltimos, kamida bitta savol qo\'shing')),
        );
        return;
      }

      // First create the test document
      final testRef = FirebaseFirestore.instance.collection('tests').doc();

      // Save basic test info
      await testRef.set({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'targetGrade': _targetGrade,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'published',
        'questionCount': _questions.length,
      });

      // Save questions as subcollection
      final batch = FirebaseFirestore.instance.batch();

      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        final questionRef = testRef.collection('questions').doc('q${i + 1}');

        batch.set(questionRef, {
          'text': question['text'],
          'options': question['options'],
          'correctIndex': question['correctIndex'],
          'order': i + 1,
        });
      }

      try {
        await batch.commit();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test muvaffaqiyatli saqlandi')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik yuz berdi: $error')),
        );
      }
    }
  }
}

Widget _buildDistrictsList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('districts').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final districts = snapshot.data!.docs;

      return ListView.builder(
        itemCount: districts.length,
        itemBuilder: (context, index) {
          final district = districts[index];
          return Card(
            child: ListTile(
              title: Text(district['name']),
              subtitle: Text(district['region']),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Get.to(() => SchoolsScreen(districtId: district.id));
              },
            ),
          );
        },
      );
    },
  );
}

class SchoolsScreen extends StatelessWidget {
  final String districtId;

  const SchoolsScreen({Key? key, required this.districtId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maktablar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maktablar ro\'yxati',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildSchoolsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('schools').where('districtId', isEqualTo: districtId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final schools = snapshot.data!.docs;

        return ListView.builder(
          itemCount: schools.length,
          itemBuilder: (context, index) {
            final school = schools[index];
            return Card(
              child: ListTile(
                title: Text(school['name']),
                subtitle: Text(school['type']),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Get.to(() => GradesScreen(schoolId: school.id));
                },
              ),
            );
          },
        );
      },
    );
  }
}

class GradesScreen extends StatelessWidget {
  final String schoolId;

  const GradesScreen({Key? key, required this.schoolId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinflar'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sinflar ro\'yxati',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildGradesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesList() {
    // In a real app, you would fetch grades from Firestore
    final grades = ['10-sinf', '11-sinf']; // Example grades

    return ListView.builder(
      itemCount: grades.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(grades[index]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Get.to(() => ClassesScreen(
                    schoolId: schoolId,
                    grade: grades[index],
                  ));
            },
          ),
        );
      },
    );
  }
}

class ClassesScreen extends StatelessWidget {
  final String schoolId;
  final String grade;

  const ClassesScreen({
    Key? key,
    required this.schoolId,
    required this.grade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$grade guruhlari'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guruhlar ro\'yxati',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildClassesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesList() {
    // In a real app, you would fetch classes from Firestore
    final classes = ['A', 'B', 'V', 'G']; // Example classes

    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text('$grade-${classes[index]}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Get.to(() => StudentsScreen(
                    schoolId: schoolId,
                    grade: grade,
                    classLetter: classes[index],
                  ));
            },
          ),
        );
      },
    );
  }
}

class StudentsScreen extends StatelessWidget {
  final String schoolId;
  final String grade;
  final String classLetter;

  const StudentsScreen({
    Key? key,
    required this.schoolId,
    required this.grade,
    required this.classLetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$grade-$classLetter o\'quvchilari'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O\'quvchilar ro\'yxati',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildStudentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('school', isEqualTo: schoolId)
          .where('grade', isEqualTo: grade)
          .where('class', isEqualTo: classLetter)
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data!.docs;

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Card(
              child: ListTile(
                title: Text(student['name']),
                subtitle: Text(student['email']),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Get.to(() => StudentDetailScreen(studentId: student.id));
                },
              ),
            );
          },
        );
      },
    );
  }
}

class StudentDetailScreen extends StatelessWidget {
  final String studentId;

  const StudentDetailScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O\'quvchi ma\'lumotlari'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = snapshot.data!;
          final testResults = student['tests'] ?? {};

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50.w,
                    backgroundColor: Colors.blue,
                    child: Text(
                      student['name'].toString().substring(0, 1),
                      style: TextStyle(fontSize: 40.sp, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    student['name'],
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    student['email'],
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildInfoCard('Maktab', student['school']),
                _buildInfoCard('Sinf', student['grade']),
                _buildInfoCard('Guruh', student['class']),
                _buildInfoCard('Ro\'li', student['role']),
                SizedBox(height: 24.h),
                Text(
                  'Test natijalari',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                if (testResults.isEmpty) Text('Hali test topshirmagan', style: TextStyle(fontSize: 16.sp)),
                ..._buildTestResults(testResults),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, dynamic value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.toString()),
      ),
    );
  }

  List<Widget> _buildTestResults(Map<String, dynamic> testResults) {
    return testResults.entries.map((entry) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: ListTile(
          title: Text(entry.key),
          subtitle: Text('Natija: ${entry.value}%'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Navigate to detailed test results
          },
        ),
      );
    }).toList();
  }
}

class AddQuestionDialog extends StatefulWidget {
  final Function(String, List<String>, int) onSave;

  const AddQuestionDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  _AddQuestionDialogState createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctOptionIndex = 0;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yangi savol qo\'shish'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Savol matni',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Variantlar',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            ..._buildOptionFields(),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: _addOption,
              child: const Text('Variant qo\'shish'),
            ),
            SizedBox(height: 16.h),
            Text(
              'To\'g\'ri javob',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            ..._buildCorrectOptionRadio(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: _saveQuestion,
          child: const Text('Saqlash'),
        ),
      ],
    );
  }

  List<Widget> _buildOptionFields() {
    return List<Widget>.generate(_optionControllers.length, (index) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _optionControllers[index],
                decoration: InputDecoration(
                  labelText: 'Variant ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            if (_optionControllers.length > 2)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeOption(index),
              ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildCorrectOptionRadio() {
    return List<Widget>.generate(_optionControllers.length, (index) {
      return RadioListTile<int>(
        title: Text('Variant ${index + 1}'),
        value: index,
        groupValue: _correctOptionIndex,
        onChanged: (value) {
          setState(() {
            _correctOptionIndex = value!;
          });
        },
      );
    });
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index);
      if (_correctOptionIndex == index) {
        _correctOptionIndex = 0;
      } else if (_correctOptionIndex > index) {
        _correctOptionIndex--;
      }
    });
  }

  void _saveQuestion() {
    final question = _questionController.text;
    final options = _optionControllers.map((c) => c.text).toList();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, savol matnini kiriting')),
      );
      return;
    }

    for (var option in options) {
      if (option.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Iltimos, barcha variantlarni to\'ldiring')),
        );
        return;
      }
    }

    widget.onSave(question, options, _correctOptionIndex);
    Navigator.pop(context);
  }
}

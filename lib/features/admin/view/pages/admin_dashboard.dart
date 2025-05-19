import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/features/admin/view/pages/location_page.dart';
import 'package:school_test_app/features/admin/view/pages/students_result_page.dart';
import 'package:school_test_app/features/admin/view/pages/survey_create_page.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin bo'limiga xush kelibsiz!",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22.sp),
            ),
            10.verticalSpace,
            Text(
              "1. Test qo'shish",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
            ),
            Text(
              "2. Shahar, Maktab va Viloyat qo'shish",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
            ),
            Text(
              "3. Test natijalari",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
            ),
            Text(
              "4. Surovnoma Yaratish",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "hero1",
            onPressed: () {
              Get.to(() => const CreateTestScreen());
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16.h),
          FloatingActionButton(
            heroTag: "hero2",
            onPressed: () {
              Get.to(() => const LocationManagementScreen());
            },
            child: Icon(Icons.location_city),
          ),
          SizedBox(height: 16.h),
          FloatingActionButton(
            heroTag: "hero3",
            onPressed: () {
              Get.to(() => const TestResultsScreen());
            },
            child: Icon(Icons.assessment),
          ),
          SizedBox(height: 16.h),
          FloatingActionButton(
            heroTag: "hero4",
            onPressed: () {
              Get.to(() => const CreateSurveyPage());
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
  String _status = 'draft';
  final List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  final List<String> _gradeOptions = [
    '10-sinf',
    '11-sinf',
  ];

  final List<String> _statusOptions = [
    'draft',
    'published',
    'archived'
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
        actions: [
          if (_status == 'draft')
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAsDraft,
              tooltip: 'Qoralama sifatida saqlash',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                items: _gradeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _targetGrade = newValue!;
                  });
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Holati',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_getStatusText(value)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
              ),
              SizedBox(height: 24.h),
              Text(
                'Savollar (${_questions.length})',
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

  String _getStatusText(String status) {
    switch (status) {
      case 'draft':
        return 'Qoralama';
      case 'published':
        return 'Nashr etilgan';
      case 'archived':
        return 'Arxivlangan';
      default:
        return status;
    }
  }

  List<Widget> _buildQuestionList() {
    if (_questions.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              'Hali savollar qo\'shilmagan',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ),
        )
      ];
    }

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
                  Expanded(
                    child: Text(
                      '${index + 1}. ${question['text']}',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editQuestion(index),
                  ),
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
          setState(() {
            _questions.add({
              'text': question,
              'options': options,
              'correctIndex': correctIndex,
            });
          });
        },
      ),
    );
  }

  void _editQuestion(int index) {
    final question = _questions[index];
    showDialog(
      context: context,
      builder: (context) => AddQuestionDialog(
        initialQuestion: question['text'],
        initialOptions: List<String>.from(question['options']),
        initialCorrectIndex: question['correctIndex'],
        onSave: (newQuestion, newOptions, newCorrectIndex) {
          setState(() {
            _questions[index] = {
              'text': newQuestion,
              'options': newOptions,
              'correctIndex': newCorrectIndex,
            };
          });
        },
      ),
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _saveAsDraft() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _saveTestToFirestore();
        Get.snackbar('Muvaffaqiyatli', 'Test qoralama sifatida saqlandi');
      } catch (error) {
        Get.snackbar('Xatolik', 'Test saqlanmadi: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _submitTest() async {
    if (_formKey.currentState!.validate()) {
      if (_questions.isEmpty) {
        Get.snackbar('Diqqat', 'Iltimos, kamida bitta savol qo\'shing');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _saveTestToFirestore();
        Get.snackbar('Muvaffaqiyatli', 'Test muvaffaqiyatli saqlandi');
        Navigator.pop(context);
      } catch (error) {
        Get.snackbar('Xatolik', 'Test saqlanmadi: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveTestToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Foydalanuvchi tizimga kirmagan');
    }

    // First create the test document
    final testRef = FirebaseFirestore.instance.collection('tests').doc();

    // Save basic test info
    await testRef.set({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'targetGrade': _targetGrade,
      'status': _status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
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
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}

class AddQuestionDialog extends StatefulWidget {
  final Function(String, List<String>, int) onSave;
  final String? initialQuestion;
  final List<String>? initialOptions;
  final int? initialCorrectIndex;

  const AddQuestionDialog({
    Key? key,
    required this.onSave,
    this.initialQuestion,
    this.initialOptions,
    this.initialCorrectIndex,
  }) : super(key: key);

  @override
  _AddQuestionDialogState createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  int _correctOptionIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize with existing data if editing
    if (widget.initialQuestion != null) {
      _questionController.text = widget.initialQuestion!;
    }

    if (widget.initialOptions != null) {
      for (var option in widget.initialOptions!) {
        _optionControllers.add(TextEditingController(text: option));
      }
    } else {
      // Default to 2 empty options
      _optionControllers.add(TextEditingController());
      _optionControllers.add(TextEditingController());
    }

    if (widget.initialCorrectIndex != null) {
      _correctOptionIndex = widget.initialCorrectIndex!;
    }
  }

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
      title: const Text('Savol qo\'shish'),
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
      Get.snackbar('Diqqat', 'Iltimos, savol matnini kiriting');
      return;
    }

    for (var option in options) {
      if (option.isEmpty) {
        Get.snackbar('Diqqat', 'Iltimos, barcha variantlarni to\'ldiring');
        return;
      }
    }

    widget.onSave(question, options, _correctOptionIndex);
    Navigator.pop(context);
  }
}
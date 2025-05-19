import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateSurveyPage extends StatefulWidget {
  const CreateSurveyPage({Key? key}) : super(key: key);

  @override
  State<CreateSurveyPage> createState() => _CreateSurveyPageState();
}

class _CreateSurveyPageState extends State<CreateSurveyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Survey details
  String _title = '';
  String _description = '';
  String _targetGrade = '11';
  SurveyType _surveyType = SurveyType.grade11;

  // Questions list
  final List<SurveyQuestion> _questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yangi so\'rovnoma yaratish', style: TextStyle(fontSize: 18.sp,color: Colors.white,)),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Survey info section
              _buildSurveyInfoSection(),
              SizedBox(height: 24.h),

              // Questions section
              _buildQuestionsSection(),
              SizedBox(height: 24.h),

              // Save button
              Center(
                child: ElevatedButton(
                  onPressed: _saveSurvey,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200.w, 50.h),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('So\'rovnomani saqlash', style: TextStyle(fontSize: 16.sp,color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('So\'rovnoma ma\'lumotlari', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),

        // Survey title
        TextFormField(
          decoration: InputDecoration(
            labelText: 'So\'rovnoma nomi',
            border: OutlineInputBorder(),
          ),
          style: TextStyle(fontSize: 16.sp),
          validator: (value) => value?.isEmpty ?? true ? 'Nomni kiriting' : null,
          onSaved: (value) => _title = value ?? '',
        ),
        SizedBox(height: 16.h),

        // Survey description
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Tavsif',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          style: TextStyle(fontSize: 16.sp),
          onSaved: (value) => _description = value ?? '',
        ),
        SizedBox(height: 16.h),

        // Target grade dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Sinflar uchun',
            border: OutlineInputBorder(),
          ),
          value: _targetGrade,
          items: ['9', '10', '11'].map((grade) {
            return DropdownMenuItem(
              value: grade,
              child: Text('$grade-sinf', style: TextStyle(fontSize: 16.sp)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _targetGrade = value ?? '11'),
        ),
        SizedBox(height: 16.h),

        // Survey type
        DropdownButtonFormField<SurveyType>(
          decoration: InputDecoration(
            labelText: 'So\'rovnoma turi',
            border: OutlineInputBorder(),
          ),
          value: _surveyType,
          items: SurveyType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.displayName, style: TextStyle(fontSize: 16.sp)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _surveyType = value ?? SurveyType.grade11),
        ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Savollar', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add, size: 24.sp),
              onPressed: _addNewQuestion,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (_questions.isEmpty)
          Center(
            child: Text('Hozircha savollar mavjud emas', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
          )
        else
          ..._questions.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionCard(index, question);
            },
          ).toList(),
      ],
    );
  }

  Widget _buildQuestionCard(int index, SurveyQuestion question) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Savol ${index + 1}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.delete, size: 20.sp, color: Colors.red),
                  onPressed: () => _removeQuestion(index),
                ),
              ],
            ),

            // Question text
            TextFormField(
              initialValue: question.text,
              decoration: InputDecoration(
                labelText: 'Savol matni',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16.sp),
              onChanged: (value) => question.text = value,
            ),
            SizedBox(height: 16.h),

            // Question type
            DropdownButtonFormField<QuestionType>(
              decoration: InputDecoration(
                labelText: 'Savol turi',
                border: OutlineInputBorder(),
              ),
              value: question.type,
              items: QuestionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName, style: TextStyle(fontSize: 16.sp)),
                );
              }).toList(),
              onChanged: (value) => setState(() => question.type = value ?? QuestionType.multipleChoice),
            ),
            SizedBox(height: 16.h),

            // Options for multiple choice
            if (question.type == QuestionType.multipleChoice) _buildOptionsSection(question),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(SurveyQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Variantlar', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        ...question.options.asMap().entries.map((entry) {
          final optionIndex = entry.key;
          final option = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: option.text,
                    decoration: InputDecoration(
                      labelText: 'Variant ${optionIndex + 1}',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: 16.sp),
                    onChanged: (value) => option.text = value,
                  ),
                ),
                SizedBox(width: 8.w),
                Checkbox(
                  value: option.isCorrect,
                  onChanged: (value) {
                    setState(() {
                      option.isCorrect = value ?? false;
                    });
                  },
                ),
                Text('To\'g\'ri', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          );
        }).toList(),
        SizedBox(height: 8.h),
        ElevatedButton(
          onPressed: () => _addOptionToQuestion(question),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 40.h),
            backgroundColor: AppColors.primaryLight,
          ),
          child: Text('Variant qo\'shish', style: TextStyle(fontSize: 14.sp)),
        ),
      ],
    );
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add(SurveyQuestion(
        text: '',
        type: QuestionType.multipleChoice,
        options: [
          SurveyOption(text: '', isCorrect: false),
          SurveyOption(text: '', isCorrect: false),
        ],
      ));
    });
  }

  void _addOptionToQuestion(SurveyQuestion question) {
    setState(() {
      question.options.add(SurveyOption(text: '', isCorrect: false));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveSurvey() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_questions.isEmpty) {
        Get.snackbar('Xatolik', 'Kamida bitta savol qo\'shing');
        return;
      }

      try {
        // Save survey to Firestore
        final surveyRef = await _firestore.collection('surveys').add({
          'title': _title,
          'description': _description,
          'targetGrade': _targetGrade,
          'type': _surveyType.toString(),
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'draft',
        });
        log(surveyRef.toString());

        // Save questions
        final batch = _firestore.batch();
        for (var question in _questions) {
          final questionRef = surveyRef.collection('questions').doc();
          batch.set(questionRef, {
            'text': question.text,
            'type': question.type.toString(),
            'order': _questions.indexOf(question),
          });

          // Save options for multiple choice questions
          if (question.type == QuestionType.multipleChoice) {
            for (var option in question.options) {
              batch.set(questionRef.collection('options').doc(), {
                'text': option.text,
                'isCorrect': option.isCorrect,
              });
            }
          }
        }

        await batch.commit();

        Get.snackbar('Muvaffaqiyatli', 'So\'rovnoma saqlandi',backgroundColor: Colors.green);
        Get.back();
      } catch (e) {
        Get.snackbar('Xatolik', 'So\'rovnoma saqlanmadi: $e');
      }
    }
    Get.back();

  }
}

enum SurveyType {
  grade9,
  grade11,
  careerInterest;

  String get displayName {
    switch (this) {
      case SurveyType.grade9:
        return '9-sinflar uchun kasbiy qiziqish';
      case SurveyType.grade11:
        return '11-sinflar uchun kelajak rejasi';
      case SurveyType.careerInterest:
        return 'Kasbiy qiziqishlar';
    }
  }
}

enum QuestionType {
  multipleChoice,
  textInput;

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Tanlov savoli';
      case QuestionType.textInput:
        return 'Matnli javob';
    }
  }
}

class SurveyQuestion {
  String text;
  QuestionType type;
  List<SurveyOption> options;

  SurveyQuestion({
    required this.text,
    required this.type,
    required this.options,
  });
}

class SurveyOption {
  String text;
  bool isCorrect;

  SurveyOption({
    required this.text,
    required this.isCorrect,
  });
}

class AppColors {
  static const Color primary = Color(0xFF0A2463);
  static const Color primaryDark = Color(0xFF001845);
  static const Color primaryLight = Color(0xFF3E7CB1);
  static const Color accent = Color(0xFFD8315B);
  static const Color background = Color(0xFFF8F9FA);
}

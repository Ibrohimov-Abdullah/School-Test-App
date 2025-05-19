import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_test_app/core/constants/constants.dart';

import '../../controllers/test_controller.dart';

class CreateTestScreen extends StatelessWidget {
  final TestController _controller = Get.put(TestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF6C63FF),
        title: Text(
          'Yangi Test Yaratish',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save_rounded),
            onPressed: _controller.saveTest,
            tooltip: 'Saqlash',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3F3FF), Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTestInfoSection(),
                SizedBox(height: 24.h),
                _buildQuestionsSection(),
                SizedBox(height: 24.h),
                _buildAddQuestionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddQuestionButton() {
    return ElevatedButton.icon(
      onPressed: _addNewQuestion,
      icon: Icon(Icons.add_circle_outline),
      label: Text('Savol qo\'shish'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 3,
      ),
    );
  }

  Widget _buildTestInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF5F5FF)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.description_outlined, color: Color(0xFF6C63FF)),
                  SizedBox(width: 10.w),
                  Text(
                    'Test Ma\'lumotlari',
                    style: GoogleFonts.montserrat(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E5A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                label: 'Test nomi',
                hint: 'Testning nomini kiriting',
                onChanged: _controller.testTitle,
                icon: Icons.title,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'Tavsif',
                hint: 'Test haqida qisqacha ma\'lumot',
                onChanged: _controller.testDescription,
                icon: Icons.info_outline,
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              _buildDropdown(),
              SizedBox(height: 16.h),
              Obx(() {
                if (_controller.testType.value == 'student') {
                  if (_controller.targetGrade.value < 1 || _controller.targetGrade.value > 11) {
                    _controller.targetGrade.value = 1;
                  }

                  return _buildGradeDropdown();
                } else {
                  return SizedBox();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(fontSize: 16.sp),
    );
  }

  Widget _buildDropdown() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _controller.testType.value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
            items: [
              DropdownMenuItem(
                value: 'student',
                child: Row(
                  children: [
                    Icon(Icons.school, color: Color(0xFF6C63FF), size: 20.r),
                    SizedBox(width: 10.w),
                    Text('O\'quvchi', style: TextStyle(fontSize: 16.sp)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'psychologist',
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: Color(0xFF6C63FF), size: 20.r),
                    SizedBox(width: 10.w),
                    Text('Psixolog', style: TextStyle(fontSize: 16.sp)),
                  ],
                ),
              ),
            ],
            onChanged: (value) => _controller.testType.value = value!,
          ),
        ),
      ),
    ));
  }

  Widget _buildGradeDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _controller.targetGrade.value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
            items: List.generate(11, (index) => index + 1)
                .map((grade) => DropdownMenuItem<int>(
              value: grade,
              child: Row(
                children: [
                  Icon(Icons.grade, color: Color(0xFF6C63FF), size: 20.r),
                  SizedBox(width: 10.w),
                  Text('$grade - sinf', style: TextStyle(fontSize: 16.sp)),
                ],
              ),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _controller.targetGrade.value = value;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Obx(() => Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Color(0xFF6C63FF).customOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.quiz_outlined, color: Color(0xFF6C63FF)),
                  SizedBox(width: 10.w),
                  Text(
                    'Savollar (${_controller.questions.length})',
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E5A),
                    ),
                  ),
                ],
              ),
              Text(
                'Jami: ${_controller.questions.length}',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        if (_controller.questions.isEmpty)
          _buildEmptyState()
        else
          ..._controller.questions.map((question) => _buildQuestionCard(question)).toList(),
      ],
    ));
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Image.network(
            'https://media.istockphoto.com/id/1292771469/photo/question-mark.jpg?s=612x612&w=0&k=20&c=e56Rl14DI9IuuC8V-eqLEC2fQ_UG08DOFPqgrkJEoP4=', // Add this placeholder image to your assets
            height: 120.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16.h),
          Text(
            'Hozircha savollar yo\'q',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Yangi savol qo\'shish uchun "Savol qo\'shish" tugmasini bosing',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getQuestionTypeIcon(question.type),
                    size: 20.r,
                    color: Color(0xFF6C63FF),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _getQuestionTypeName(question.type),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    onPressed: () => _controller.removeQuestion(_controller.questions.indexOf(question)),
                    tooltip: 'O\'chirish',
                    iconSize: 20.r,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 8.h),
              Text(
                question.text,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              if (question.options.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  'Variantlar:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: question.options
                      .map((option) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ))
                      .toList(),
                ),
              ],
              if (question.correctAnswer.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 18.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'To\'g\'ri javob: ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      question.correctAnswer,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'multiple_choice':
        return Icons.radio_button_checked;
      case 'dropdown':
        return Icons.arrow_drop_down_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getQuestionTypeName(String type) {
    switch (type) {
      case 'text':
        return 'Matn';
      case 'multiple_choice':
        return 'Test';
      case 'dropdown':
        return 'Tanlov';
      default:
        return 'Noma\'lum';
    }
  }

  void _addNewQuestion() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yangi Savol Qo\'shish',
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E5A),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 10.h),
            Expanded(
              child: SingleChildScrollView(
                child: QuestionForm(
                  onSave: (question) {
                    _controller.addQuestion(question);
                    Get.back();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class QuestionForm extends StatefulWidget {
  final Function(Question) onSave;

  QuestionForm({required this.onSave});

  @override
  _QuestionFormState createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  String _questionType = 'text';
  final _optionsController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _options = <String>[];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _questionTextController,
            decoration: InputDecoration(
              labelText: 'Savol matni',
              hintText: 'Savolni kiriting',
              prefixIcon: Icon(Icons.help_outline, color: Color(0xFF6C63FF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Majburiy maydon' : null,
            maxLines: 3,
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: _questionType,
            decoration: InputDecoration(
              labelText: 'Savol turi',
              prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF6C63FF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'text',
                child: Text('Matn'),
              ),
              DropdownMenuItem(
                value: 'multiple_choice',
                child: Text('Test'),
              ),
              DropdownMenuItem(
                value: 'dropdown',
                child: Text('Tanlov'),
              ),
            ],
            onChanged: (value) => setState(() => _questionType = value!),
          ),
          if (_questionType == 'multiple_choice' || _questionType == 'dropdown') ...[
            SizedBox(height: 20.h),
            Text(
              'Variantlar:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E2E5A),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _optionsController,
                    decoration: InputDecoration(
                      labelText: 'Variant qo\'shish',
                      hintText: 'Variantni kiriting',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    if (_optionsController.text.isNotEmpty) {
                      setState(() {
                        _options.add(_optionsController.text);
                        _optionsController.clear();
                      });
                    }
                  },
                  child: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    padding: EdgeInsets.all(15.r),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
            if (_options.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _options
                      .map((option) => Chip(
                    label: Text(option),
                    deleteIcon: Icon(Icons.close, size: 18.r),
                    onDeleted: () => setState(() => _options.remove(option)),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF6C63FF).customOpacity(0.3)),
                    labelStyle: TextStyle(color: Color(0xFF2E2E5A)),
                  ))
                      .toList(),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _correctAnswerController,
                decoration: InputDecoration(
                  labelText: 'To\'g\'ri javob',
                  hintText: 'To\'g\'ri javobni kiriting',
                  prefixIcon: Icon(Icons.check_circle_outline, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Majburiy maydon' : null,
              ),
            ],
          ],
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _submitForm,
            icon: Icon(Icons.save),
            label: Text('Savolni saqlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(Question(
        text: _questionTextController.text,
        type: _questionType,
        options: _options,
        correctAnswer: _correctAnswerController.text,
      ));
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _optionsController.dispose();
    _correctAnswerController.dispose();
    super.dispose();
  }
}


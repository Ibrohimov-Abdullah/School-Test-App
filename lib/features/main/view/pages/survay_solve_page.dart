import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_test_app/features/main/view/pages/main_page.dart';

import '../../../admin/view/pages/survey_create_page.dart';

class SolveSurveyPage extends StatefulWidget {
  final String surveyId;

  const SolveSurveyPage({Key? key, required this.surveyId}) : super(key: key);

  @override
  State<SolveSurveyPage> createState() => _SolveSurveyPageState();
}

class _SolveSurveyPageState extends State<SolveSurveyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();

  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;

  String _surveyTitle = '';
  String _surveyDescription = '';

  List<SurveyQuestion> _questions = [];
  List<dynamic> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    try {
      // ... (keep your existing loading code)

      // Total pages = info page + questions + submit page
      _totalPages = _questions.length + 2; // +2 for info and submit pages

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Xatolik', 'So\'rovnoma yuklanmadi: $e');
      Get.back();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_surveyTitle, style: TextStyle(fontSize: 18.sp,color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            minHeight: 4.h,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildSurveyInfoPage(),
                ..._questions.map((question) => _buildQuestionPage(question)).toList(),
                _buildSubmitPage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildSurveyInfoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('So\'rovnoma haqida', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Text(_surveyDescription, style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 24.h),
          Text('Savollar soni: $_totalPages', style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 32.h),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentPage = 1);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200.w, 50.h),
                backgroundColor: AppColors.primary,
              ),
              child: Text('Boshlash', style: TextStyle(fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(SurveyQuestion question) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Savol ${_questions.indexOf(question) + 1}/$_totalPages',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
          SizedBox(height: 16.h),
          Text(question.text, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 24.h),

          if (question.type == QuestionType.multipleChoice)
            ...question.options.map((option) {
              return _buildOptionButton(question, option);
            }).toList()
          else
            TextField(
              decoration: InputDecoration(
                labelText: 'Javobingiz',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              style: TextStyle(fontSize: 16.sp),
              onChanged: (value) {
                _answers[_questions.indexOf(question)] = value;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(SurveyQuestion question, SurveyOption option) {
    final isSelected = _answers[_questions.indexOf(question)] == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _answers[_questions.indexOf(question)] = option;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              )
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(option.text, style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitPage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64.sp, color: AppColors.primary),
            SizedBox(height: 24.h),
            Text('So\'rovnoma yakunlandi', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Text('Javoblaringizni tekshirib, yakunlash tugmasini bosing',
                style: TextStyle(fontSize: 16.sp), textAlign: TextAlign.center),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: _submitSurvey,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200.w, 50.h),
                backgroundColor: AppColors.primary,
              ),
              child: Text('Yakunlash', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    ); 
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentPage--);
                },
                child: Text('Orqaga', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          if (_currentPage > 0) SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Check if current question is answered (except for info and submit pages)
                if (_currentPage > 0 && _currentPage <= _questions.length) {
                  if (_answers[_currentPage - 1] == null) {
                    Get.snackbar('Diqqat', 'Iltimos, savolga javob bering');
                    return;
                  }
                }

                if (_currentPage < _totalPages - 1) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentPage++);
                } else {
                  // This is the submit page
                  _submitSurvey();
                }
              },
              child: Text(
                _currentPage == 0
                    ? 'Boshlash'
                    : _currentPage == _totalPages - 1
                    ? 'Yakunlash'
                    : 'Keyingisi',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitSurvey() async {
    try {
      final userId = 'current_user_id'; // Replace with actual user ID

      // Save survey results
      await _firestore.collection('survey_results').add({
        'surveyId': widget.surveyId,
        'userId': userId,
        'answers': _answers,
        'completedAt': FieldValue.serverTimestamp(),
      });

      Get.offAll(() => SurveyCompletedPage(surveyId: widget.surveyId));
    } catch (e) {
      Get.snackbar('Xatolik', 'Javoblar saqlanmadi: $e');
    }
  }
}

class SurveyCompletedPage extends StatelessWidget {
  final String surveyId;

  const SurveyCompletedPage({Key? key, required this.surveyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80.sp, color: Colors.green),
              SizedBox(height: 24.h),
              Text('Rahmat!', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              Text('Sizning javoblaringiz muvaffaqiyatli qabul qilindi',
                  style: TextStyle(fontSize: 18.sp), textAlign: TextAlign.center),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () => Get.offAll(MainPage()),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200.w, 50.h),
                  backgroundColor: AppColors.primary,
                ),
                child: Text('Bosh menyu', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_test_app/core/constants/constants.dart';
import 'package:school_test_app/features/main/view/pages/test_page.dart';
import 'package:school_test_app/core/data/models/survey_model.dart';
import 'package:school_test_app/features/main/view/pages/test_result_page.dart';
import '../../../themes/app_colors.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables to store surveys
  List<Survey> _availableSurveys = [];
  List<Survey> _completedSurveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
    salom();
  }

  Future<void> _fetchSurveys() async {
    try {
      // Fetch available surveys (published status)
      final availableQuery = await _firestore.collection('tests').where('status', isEqualTo: 'published').get();

      _availableSurveys = availableQuery.docs.map((doc) {
        return Survey(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          questions: [],
          // We'll fetch questions separately if needed
          createdAt: doc['createdAt'].toDate(),
          status: SurveyStatus.published,
          targetGrade: doc['targetGrade'],
          accentColor: AppColors.primary,
        );
      }).toList();

      // Fetch completed surveys (you'll need to track which surveys the user has completed)
      // This is a placeholder - you'll need to implement your own logic
      // based on how you track completed surveys in Firestore
      final completedQuery = await _firestore
          .collection('user_test_results')
          .where('userId', isEqualTo: 'current_user_id') // Replace with actual user ID
          .get();

      // For each completed test, fetch the test details
      for (var resultDoc in completedQuery.docs) {
        final testDoc = await _firestore.collection('tests').doc(resultDoc['testId']).get();

        if (testDoc.exists) {
          _completedSurveys.add(Survey(
            id: testDoc.id,
            title: testDoc['title'],
            description: testDoc['description'],
            questions: [],
            createdAt: testDoc['createdAt'].toDate(),
            status: SurveyStatus.closed,
            targetGrade: testDoc['targetGrade'],
            accentColor: AppColors.accent1,
            score: resultDoc['score'], // Add score to the model if needed
          ));
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Failed to load surveys: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _isLoading ? _buildLoadingIndicator() : _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primary.customOpacity(0.2),
            child: Text(
              'AS',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Alisher',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Grade 10-A',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.inputFillLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Available', 0),
          ),
          Expanded(
            child: _buildTabButton('Completed', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildSurveyList(_availableSurveys);
      case 1:
        return _buildSurveyList(_completedSurveys);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSurveyList(List<Survey> surveys) {
    if (surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64.sp,
              color: AppColors.textGrey,
            ),
            SizedBox(height: 16.h),
            Text(
              'No surveys available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: surveys.length,
      itemBuilder: (context, index) {
        final survey = surveys[index];
        return _buildSurveyCard(survey);
      },
    );
  }

  Widget _buildSurveyCard(Survey survey) {
    final isCompleted = survey.status == SurveyStatus.closed;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.customOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with accent color
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: survey.accentColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and status indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        survey.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.success.customOpacity(0.1) : AppColors.primary.customOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        isCompleted ? 'Completed' : 'Available',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: isCompleted ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Description
                Text(
                  survey.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                  ),
                ),

                SizedBox(height: 16.h),

                // Additional info
                Row(
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 16.sp,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Grade ${survey.targetGrade}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.help_outline,
                      size: 16.sp,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isCompleted ? 'Score: ${survey.score}%' : 'Start anytime',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Start survey
                      Get.to(
                        TestScreen(),
                        arguments: survey.id, // Pass the test ID
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.grey.shade200 : AppColors.primary,
                      foregroundColor: isCompleted ? AppColors.textGrey : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      isCompleted ? 'View Results' : 'Start Survey',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/** bu funksiya menga salom degan so'zni chiqarib beradi */
void salom() {

}

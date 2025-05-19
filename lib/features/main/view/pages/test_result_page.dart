import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:school_test_app/core/constants/constants.dart';
import 'package:school_test_app/features/main/view/pages/main_page.dart';
import 'package:school_test_app/features/main/view/pages/students_dashboard.dart';

class TestResultScreen extends StatefulWidget {
  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final String testId;

  const TestResultScreen({
    Key? key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.testId,
  }) : super(key: key);

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 30.h),
              _buildScoreSection(),
              SizedBox(height: 30.h),
              _buildTestDetailsSection(),
              SizedBox(height: 30.h),
              _buildActionButtons(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        SizedBox(width: 10.w),
        Text(
          'Test natijalari',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CircularPercentIndicator(
                radius: 100.w,
                lineWidth: 10.w,
                percent: _animation.value,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(_animation.value * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Umumiy ball',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                progressColor: _getScoreColor(widget.score),
              );
            },
          ),
          SizedBox(height: 16.h),
          Text(
            _getPerformanceMessage(widget.score),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(widget.score),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestDetailsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.customOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test tafsilotlari',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow('To\'g\'ri javoblar',
              '${widget.correctAnswers}/${widget.totalQuestions}'),
          _buildDetailRow('Foiz', '${widget.score.toStringAsFixed(1)}%'),
          _buildDetailRow('Test ID', widget.testId),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Get.offAll(MainPage());
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50.h),
          ),
          child: Text(
            'Asosiy menyu',
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getPerformanceMessage(double score) {
    if (score >= 90) return 'Ajoyib natija!';
    if (score >= 80) return 'Judayam yaxshi!';
    if (score >= 70) return 'Yaxshi ish!';
    if (score >= 60) return 'Qoniqarli';
    return 'Yaxshilash kerak';
  }
}
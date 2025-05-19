import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_test_app/core/constants/constants.dart';
import 'package:school_test_app/features/main/view/pages/survay_solve_page.dart';

import '../../../admin/view/pages/survey_create_page.dart';

class SurveysListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SurveysListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('So\'rovnomalar', style: TextStyle(fontSize: 18.sp,color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('surveys').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('So\'rovnomalar topilmadi', style: TextStyle(fontSize: 16.sp)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final survey = snapshot.data!.docs[index];
              return _buildSurveyCard(survey);
            },
          );
        },
      ),
    );
  }

  Widget _buildSurveyCard(QueryDocumentSnapshot survey) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () => Get.to(() => SolveSurveyPage(surveyId: survey.id)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey['title'],
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${survey['targetGrade']}-sinflar uchun',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16.sp),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                survey['description'],
                style: TextStyle(fontSize: 14.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.event, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    'Yaratilgan: ${_formatDate(survey['createdAt']?.toDate())}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: survey['status'] == 'published'
                          ? Colors.green.customOpacity(0.1)
                          : Colors.orange.customOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      survey['status'] == 'published' ? 'Faol' : 'Qoralama',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: survey['status'] == 'published'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Noma\'lum';
    return '${date.day}.${date.month}.${date.year}';
  }
}
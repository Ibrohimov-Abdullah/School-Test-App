import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/core/constants/constants.dart';
import 'package:school_test_app/features/main/view/pages/test_result_page.dart';
import 'package:school_test_app/features/profile/view/profile_page.dart';
import 'package:uzpay/enums.dart';
import 'package:uzpay/objects.dart';
import 'package:uzpay/uzpay.dart';

import '../../../themes/app_colors.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalPages = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Added auth instance

  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _testId;
  List<int> _selectedAnswers = [];
  bool _paymentCompleted = false;
  bool _isPaymentProcessing = false;

  List<TextEditingController> _textAnswerControllers = [];
  List<bool> _useTextAnswer = [];

  @override
  void initState() {
    super.initState();
    _testId = Get.arguments;
    if (_testId != null) {
      _fetchTestInfo();
    }
  }

  @override
  void dispose() {
    for (var controller in _textAnswerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchTestInfo() async {
    try {
      final testDoc = await _firestore.collection('tests').doc(_testId).get();
      if (testDoc.exists) {
        final questionsQuery = await _firestore.collection('tests').doc(_testId).collection('questions').orderBy('order').get();

        _questions = questionsQuery.docs.map((doc) => doc.data()).toList();
        _totalPages = _questions.length;
        _selectedAnswers = List.filled(_totalPages, -1);
        _textAnswerControllers = List.generate(_totalPages, (index) => TextEditingController());
        _useTextAnswer = List.filled(_totalPages, false);

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Xatolik', 'Test yuklanmadi: $e');
    }
  }

  // Replace _processPayment with this
  Future<void> _processPayment() async {
    setState(() {
      _isPaymentProcessing = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Xatolik', 'Foydalanuvchi tizimga kirmagan');
        return;
      }

      // Check balance
      final balanceDoc = await _firestore.collection('balances').doc(user.uid).get();
      final currentBalance = balanceDoc.exists ? (balanceDoc['amount'] ?? 0) : 0;
      const testPrice = 2000;

      if (currentBalance >= testPrice) {
        // Deduct from balance
        await _firestore.collection('balances').doc(user.uid).update({
          'amount': FieldValue.increment(-testPrice),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Record transaction
        await _firestore.collection('transactions').add({
          'userId': user.uid,
          'amount': -testPrice,
          'description': 'Test uchun to\'lov ($_testId)',
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _paymentCompleted = true;
          _isPaymentProcessing = false;
        });
      } else {
        // If balance is insufficient, offer to top up via UzPay
        setState(() {
          _isPaymentProcessing = false;
        });

        final result = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Balans yetarli emas'),
            content: Text(
              'Balansingizda yetarli mablag\' yo\'q (${currentBalance} so\'m). 2000 so\'m to\'lov qilish uchun balansingizni to\'ldirish kerak.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Bekor qilish'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('To\'ldirish'),
              ),
            ],
          ),
        );

        if (result == true) {
          // Process payment via UzPay
          var paymentParams = Params(
            clickParams: ClickParams(
              transactionParam: "Balans to'ldirish",
              merchantId: "37061",
              serviceId: "69003",
              merchantUserId: "53110",
            ),
          );

          var paymentResult = await UzPay.doPayment(
            context,
            amount: 2000,
            paymentSystem: PaymentSystem.Click,
            paymentParams: paymentParams,
            browserType: BrowserType.ExternalOrDeepLink,
          );

            // Top up balance after successful payment
            await _firestore.collection('balances').doc(user.uid).set({
              'amount': FieldValue.increment(2000),
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            // Record transaction
            await _firestore.collection('transactions').add({
              'userId': user.uid,
              'amount': 2000,
              'description': 'Balans to\'ldirish',
              'paymentId': paymentResult.transactionId,
              'createdAt': FieldValue.serverTimestamp(),
            });

            Get.snackbar('Muvaffaqiyatli', 'Balansingiz 2000 so\'mga to\'ldirildi');

            // Retry the test payment
            await _processPayment();
          } else {
            Get.snackbar('Xatolik', 'To\'lov amalga oshirilmadi');
          }
        }
    } catch (e) {
      setState(() {
        _isPaymentProcessing = false;
      });
      Get.snackbar('Xatolik', 'To\'lov jarayonida xatolik: $e');
    }
  }
  Widget _buildPaymentScreen() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 60.w,
            color: AppColors.primary,
          ),
          SizedBox(height: 20.h),
          Text(
            'Testni boshlash uchun to\'lov qiling',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            'Test narxi: 2000 so\'m',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('balances').doc(_auth.currentUser?.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              final balance = snapshot.data?.exists ?? false
                  ? (snapshot.data!['amount'] ?? 0)
                  : 0;
              return Text(
                'Balansingiz: $balance so\'m',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: balance >= 2000 ? AppColors.success : AppColors.error,
                ),
              );
            },
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: _isPaymentProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50.h),
            ),
            child: _isPaymentProcessing
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              'Balansdan to\'lash',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () {
              Get.back();
              Get.to(ProfilePage());
            },
            child: Text(
              'Balansni to\'ldirish',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (index >= _questions.length) {
      return Center(child: Text('Savol topilmadi'));
    }

    final question = _questions[index];
    final options = question['options'] as List<dynamic>;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Savol ${index + 1} dan $_totalPages',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            question['text'],
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          ...options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final optionText = entry.value as String;
            return _buildOptionTile(
              optionText,
              optionIndex,
              index,
            );
          }).toList(),

          // Add this for the text answer option
          SizedBox(height: 16.h),
          _buildTextAnswerOption(index),
        ],
      ),
    );
  }

  Widget _buildTextAnswerOption(int questionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _useTextAnswer[questionIndex],
              onChanged: (value) {
                setState(() {
                  _useTextAnswer[questionIndex] = value ?? false;
                  if (!_useTextAnswer[questionIndex]) {
                    _textAnswerControllers[questionIndex].clear();
                  } else {
                    _selectedAnswers[questionIndex] = -2; // Special value for text answer
                  }
                });
              },
            ),
            Text('Boshqa javob yozish', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
        if (_useTextAnswer[questionIndex])
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: TextField(
              controller: _textAnswerControllers[questionIndex],
              decoration: InputDecoration(
                hintText: 'Javobingizni yozing...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Update the selected answer when text changes
                if (value.isNotEmpty) {
                  _selectedAnswers[questionIndex] = -2; // Special value for text answer
                } else {
                  _selectedAnswers[questionIndex] = -1;
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOptionTile(String optionText, int optionIndex, int questionIndex) {
    final isSelected = _selectedAnswers[questionIndex] == optionIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswers[questionIndex] = optionIndex;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.customOpacity(0.1) : Colors.white,
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
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTest() async {
    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correctIndex']) {
        correctAnswers++;
      }
    }
    final double score = (correctAnswers / _questions.length) * 100;

    // Save results to Firestore
    try {
      final userId = _auth.currentUser?.uid; // Replace with actual user ID
      await _firestore.collection('user_test_results').add({
        'userId': userId,
        'testId': _testId,
        'score': score,
        'fullName':_auth.currentUser?.displayName,
        'correctAnswers': correctAnswers,
        'totalQuestions': _questions.length,
        'answers': _selectedAnswers,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Update user's test history
      await _firestore.collection('users').doc(userId).update({
        'completedTests': FieldValue.arrayUnion([_testId]),
      });

      // Navigate to results screen
      Get.off(
        TestResultScreen(
          score: score,
          correctAnswers: correctAnswers,
          totalQuestions: _questions.length,
          testId: _testId!,
        ),
      );
    } catch (e) {
      Get.snackbar('Xatolik', 'Test topshirilmadi: $e');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    } else {
      _submitTest();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
        centerTitle: true,
      ),
      body: _paymentCompleted ? _buildTestContent() : _buildPaymentScreen(),
    );
  }

  Widget _buildTestContent() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentPage + 1) / _totalPages,
          minHeight: 4.h,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _totalPages,
            itemBuilder: (context, index) => _buildQuestionPage(index),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    child: Text('Orqaga', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
              if (_currentPage > 0) SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedAnswers[_currentPage] == -1 ? null : _nextPage,
                  child: Text(
                    _currentPage == _totalPages - 1 ? 'Yakunlash' : 'Keyingisi',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uzpay/enums.dart';
import 'package:uzpay/objects.dart';
import 'package:uzpay/uzpay.dart';

class TestOffController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString testId = RxnString();
  final RxList<int> selectedAnswers = <int>[].obs;
  final RxBool paymentCompleted = false.obs;
  final RxBool isPaymentProcessing = false.obs;

  final List<TextEditingController> textAnswerControllers = [];
  final RxList<bool> useTextAnswer = <bool>[].obs;

  @override
  void onInit() {
    testId.value = Get.arguments;
    if (testId.value != null) {
      fetchTestInfo();
    }
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    for (var controller in textAnswerControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> fetchTestInfo() async {
    try {
      isLoading(true);
      final testDoc = await firestore.collection('tests').doc(testId.value).get();
      if (testDoc.exists) {
        final questionsQuery = await firestore
            .collection('tests')
            .doc(testId.value)
            .collection('questions')
            .orderBy('order')
            .get();

        questions.assignAll(questionsQuery.docs.map((doc) => doc.data()));
        totalPages.value = questions.length;
        selectedAnswers.assignAll(List.filled(questions.length, -1));
        textAnswerControllers.clear();
        textAnswerControllers.addAll(
            List.generate(questions.length, (index) => TextEditingController()));
        useTextAnswer.assignAll(List.filled(questions.length, false));

        isLoading(false);
      }
    } catch (e) {
      isLoading(false);
      Get.snackbar('Xatolik', 'Test yuklanmadi: $e');
    }
  }

  Future<void> processPayment() async {
    isPaymentProcessing(true);
    try {
      final user = auth.currentUser;
      if (user == null) {
        Get.snackbar('Xatolik', 'Foydalanuvchi tizimga kirmagan');
        return;
      }

      final balanceDoc = await firestore.collection('balances').doc(user.uid).get();
      final currentBalance = balanceDoc.exists ? (balanceDoc['amount'] ?? 0) : 0;
      const testPrice = 2000;

      if (currentBalance >= testPrice) {
        await firestore.collection('balances').doc(user.uid).update({
          'amount': FieldValue.increment(-testPrice),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        await firestore.collection('transactions').add({
          'userId': user.uid,
          'amount': -testPrice,
          'description': 'Test uchun to\'lov (${testId.value})',
          'createdAt': FieldValue.serverTimestamp(),
        });

        paymentCompleted(true);
      } else {
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
          var paymentParams = Params(
            clickParams: ClickParams(
              transactionParam: "Balans to'ldirish",
              merchantId: "37061",
              serviceId: "69003",
              merchantUserId: "53110",
            ),
          );

          var paymentResult = await UzPay.doPayment(
            Get.context!,
            amount: 2000,
            paymentSystem: PaymentSystem.Click,
            paymentParams: paymentParams,
            browserType: BrowserType.ExternalOrDeepLink,
          );

          await firestore.collection('balances').doc(user.uid).set({
            'amount': FieldValue.increment(2000),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          await firestore.collection('transactions').add({
            'userId': user.uid,
            'amount': 2000,
            'description': 'Balans to\'ldirish',
            'paymentId': paymentResult.transactionId,
            'createdAt': FieldValue.serverTimestamp(),
          });

          Get.snackbar('Muvaffaqiyatli', 'Balansingiz 2000 so\'mga to\'ldirildi');
          await processPayment();
        }
      }
    } catch (e) {
      Get.snackbar('Xatolik', 'To\'lov jarayonida xatolik: $e');
    } finally {
      isPaymentProcessing(false);
    }
  }

  void toggleTextAnswer(int questionIndex, bool value) {
    useTextAnswer[questionIndex] = value;
    if (!value) {
      textAnswerControllers[questionIndex].clear();
    } else {
      selectedAnswers[questionIndex] = -2;
    }
    useTextAnswer.refresh();
  }

  void updateTextAnswer(int questionIndex, String value) {
    if (value.isNotEmpty) {
      selectedAnswers[questionIndex] = -2;
    } else {
      selectedAnswers[questionIndex] = -1;
    }
  }

  void selectAnswer(int questionIndex, int answerIndex) {
    selectedAnswers[questionIndex] = answerIndex;
  }

  void nextPage() {
    if (currentPage.value < totalPages.value - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    } else {
      submitTest();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
    }
  }

  Future<void> submitTest() async {
    int correctAnswers = 0;
    List<String> userAnswers = [];

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == -2) {
        userAnswers.add(textAnswerControllers[i].text);
      } else {
        userAnswers.add(questions[i]['options'][selectedAnswers[i]]);
        if (selectedAnswers[i] == questions[i]['correctIndex']) {
          correctAnswers++;
        }
      }
    }

    final double score = (correctAnswers / questions.length) * 100;

    try {
      final userId = auth.currentUser?.uid;
      await firestore.collection('user_test_results').add({
        'userId': userId,
        'testId': testId.value,
        'score': score,
        'fullName': auth.currentUser?.displayName,
        'correctAnswers': correctAnswers,
        'totalQuestions': questions.length,
        'answers': selectedAnswers,
        'textAnswers': textAnswerControllers.map((c) => c.text).toList(),
        'usedTextAnswer': useTextAnswer,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('users').doc(userId).update({
        'completedTests': FieldValue.arrayUnion([testId.value]),
      });

      Get.offNamed('/test_result', arguments: {
        'score': score,
        'correctAnswers': correctAnswers,
        'totalQuestions': questions.length,
        'testId': testId.value,
      });
    } catch (e) {
      Get.snackbar('Xatolik', 'Test topshirilmadi: $e');
    }
  }

  bool get isNextButtonEnabled {
    return !((selectedAnswers[currentPage.value] == -1 &&
        !useTextAnswer[currentPage.value]) ||
        (useTextAnswer[currentPage.value] &&
            textAnswerControllers[currentPage.value].text.isEmpty));
  }
}
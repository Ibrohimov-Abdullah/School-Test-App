import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final testTitle = ''.obs;
  final testDescription = ''.obs;
  final testType = 'student'.obs; // 'student' or 'psychologist'
  final targetGrade = 0.obs;
  final questions = <Question>[].obs;
  final isLoading = false.obs;

  void addQuestion(Question question) {
    questions.add(question);
  }

  void removeQuestion(int index) {
    questions.removeAt(index);
  }

  Future<void> saveTest() async {
    try {
      isLoading(true);
      await _firestore.collection('tests').add({
        'title': testTitle.value,
        'description': testDescription.value,
        'type': testType.value,
        'targetGrade': targetGrade.value,
        'questions': questions.map((q) => q.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.back();
      Get.snackbar('Success', 'Test created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create test: $e');
    } finally {
      isLoading(false);
    }
  }
}

class Question {
  final String text;
  final String type; // 'text', 'multiple_choice', 'dropdown'
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.text,
    required this.type,
    this.options = const [],
    this.correctAnswer = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}
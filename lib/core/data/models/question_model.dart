import 'package:flutter/material.dart';

enum QuestionType {
  singleChoice, // Radio buttons
  multipleChoice, // Checkboxes
  text, // Free text input
  number, // Number input
  dropdown, // Dropdown selection
}

class Option {
  final String id;
  final String text;
  final bool isOther; // For "Other" options that may require additional input
  final String? additionalInputHint;

  Option({
    required this.id,
    required this.text,
    this.isOther = false,
    this.additionalInputHint,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      text: json['text'],
      isOther: json['isOther'] ?? false,
      additionalInputHint: json['additionalInputHint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isOther': isOther,
      'additionalInputHint': additionalInputHint,
    };
  }
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<Option>? options; // For choice-based questions
  final bool isRequired;
  final String? hint;
  final bool hasFollowUp; // If this question might lead to a follow-up question
  final String? followUpQuestion; // The actual follow-up question text
  final QuestionType? followUpType; // Type of the follow-up question

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.isRequired = true,
    this.hint,
    this.hasFollowUp = false,
    this.followUpQuestion,
    this.followUpType,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: QuestionType.values.firstWhere(
            (e) => e.toString() == 'QuestionType.${json['type']}',
        orElse: () => QuestionType.singleChoice,
      ),
      options: json['options'] != null
          ? List<Option>.from(json['options'].map((x) => Option.fromJson(x)))
          : null,
      isRequired: json['isRequired'] ?? true,
      hint: json['hint'],
      hasFollowUp: json['hasFollowUp'] ?? false,
      followUpQuestion: json['followUpQuestion'],
      followUpType: json['followUpType'] != null
          ? QuestionType.values.firstWhere(
            (e) => e.toString() == 'QuestionType.${json['followUpType']}',
        orElse: () => QuestionType.text,
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'options': options?.map((x) => x.toJson()).toList(),
      'isRequired': isRequired,
      'hint': hint,
      'hasFollowUp': hasFollowUp,
      'followUpQuestion': followUpQuestion,
      'followUpType': followUpType?.toString().split('.').last,
    };
  }

  // Helper method to check if this is a choice-based question
  bool get isChoiceBased =>
      type == QuestionType.singleChoice ||
          type == QuestionType.multipleChoice ||
          type == QuestionType.dropdown;
}

class Answer {
  final String questionId;
  final dynamic value; // String for text, List<String> for multi-choice, String for single choice
  final String? followUpAnswer; // If there was a follow-up question

  Answer({
    required this.questionId,
    required this.value,
    this.followUpAnswer,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['questionId'],
      value: json['value'],
      followUpAnswer: json['followUpAnswer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'value': value,
      'followUpAnswer': followUpAnswer,
    };
  }
}

class Question2 {
  final String text;
  final String type;
  final List<String> options;
  final String correctAnswer;

  Question2({
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswer,
  });

  // Add a copy method for easy modification of question properties
  Question2 copyWith({
    String? text,
    String? type,
    List<String>? options,
    String? correctAnswer,
  }) {
    return Question2(
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }

  // Convert Question to a Map (useful for serialization)
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  // Create a Question from a Map (useful for deserialization)
  factory Question2.fromMap(Map<String, dynamic> map) {
    return Question2(
      text: map['text'] ?? '',
      type: map['type'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
    );
  }
}
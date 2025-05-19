import 'package:flutter/cupertino.dart';

enum SurveyStatus { draft, published, closed }

class Survey {
  final String id;
  final String title;
  final String description;
  final List<dynamic> questions;
  final DateTime createdAt;
  final SurveyStatus status;
  final String targetGrade;
  final Color accentColor;
  final double? score;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdAt,
    required this.status,
    required this.targetGrade,
    required this.accentColor,
    this.score,
  });
}
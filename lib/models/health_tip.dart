import 'package:flutter/material.dart';

class HealthTip {
  final String id;
  final String title;
  final String category; // 'Dinh dưỡng', 'Vận động', 'Giấc ngủ', 'Tinh thần'
  final String author;
  final String readTime;
  final String summary;
  final List<String> bulletPoints;
  final IconData icon;
  final Color themeColor;

  HealthTip({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.readTime,
    required this.summary,
    required this.bulletPoints,
    required this.icon,
    required this.themeColor,
  });
}

import 'package:flutter/material.dart';

class AthletePlan {
  final String id;
  final String name;
  final String role;
  final String avatarEmoji;
  final String tagline;
  final Color themeColor;

  // Goals
  final int dailyWaterMl;
  final double dailySleepHours;
  final int dailyActivityMinutes;

  // Detailed Plans
  final List<String> workoutRoutine;
  final List<String> mealPlan;
  final List<String> sleepTips;
  final String proTip;

  AthletePlan({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarEmoji,
    required this.tagline,
    required this.themeColor,
    required this.dailyWaterMl,
    required this.dailySleepHours,
    required this.dailyActivityMinutes,
    required this.workoutRoutine,
    required this.mealPlan,
    required this.sleepTips,
    required this.proTip,
  });
}

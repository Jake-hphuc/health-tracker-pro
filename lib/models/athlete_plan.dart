import 'package:flutter/material.dart';

class AthletePlan {
  final String id;
  final String name;
  final String role;
  final String avatarEmoji;
  final String proTip;
  final int dailyWaterMl;
  final double dailySleepHours;
  final int dailyActivityMinutes;
  final List<String> workoutRoutine;
  final List<String> mealPlan;
  final List<String> sleepTips;
  final Color themeColor;

  const AthletePlan({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarEmoji,
    required this.proTip,
    required this.dailyWaterMl,
    required this.dailySleepHours,
    required this.dailyActivityMinutes,
    required this.workoutRoutine,
    required this.mealPlan,
    required this.sleepTips,
    required this.themeColor,
  });
}

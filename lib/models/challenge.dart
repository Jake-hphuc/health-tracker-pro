import 'package:flutter/material.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String month;
  final int targetValue;
  final String unit;
  final int currentProgress;
  final int rewardPoints;
  final String badgeName;
  final IconData badgeIcon;
  final Color themeColor;
  final bool isClaimed;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.month,
    required this.targetValue,
    required this.unit,
    required this.currentProgress,
    required this.rewardPoints,
    required this.badgeName,
    required this.badgeIcon,
    required this.themeColor,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= targetValue;
  double get progressRatio => (currentProgress / targetValue).clamp(0.0, 1.0);

  Challenge copyWith({
    int? currentProgress,
    bool? isClaimed,
  }) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      month: month,
      targetValue: targetValue,
      unit: unit,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardPoints: rewardPoints,
      badgeName: badgeName,
      badgeIcon: badgeIcon,
      themeColor: themeColor,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class BadgeReward {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String unlockedDate;

  BadgeReward({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlockedDate,
  });
}

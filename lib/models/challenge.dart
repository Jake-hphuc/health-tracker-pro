import 'package:flutter/material.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentProgress;
  final String unit;
  final int rewardPoints;
  final IconData badgeIcon;
  final Color badgeColor;
  final String category; // 'Nước uống', 'Vận động', 'Giấc ngủ', 'Đăng nhập'
  final bool isCompleted;
  final bool isClaimed;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentProgress,
    required this.unit,
    required this.rewardPoints,
    required this.badgeIcon,
    required this.badgeColor,
    required this.category,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? targetValue,
    int? currentProgress,
    String? unit,
    int? rewardPoints,
    IconData? badgeIcon,
    Color? badgeColor,
    String? category,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      unit: unit ?? this.unit,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      badgeColor: badgeColor ?? this.badgeColor,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

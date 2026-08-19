import 'package:flutter/material.dart';

class HealthSchedule {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String scheduleType; // Uống nước, Tập luyện, Ăn uống, Ngủ, Đo cân nặng, Khác
  final String scheduledTime; // "06:30", "17:30"
  final String repeatType; // Một lần, Hàng ngày, Hàng tuần
  final bool isCompleted;
  final String date; // "yyyy-MM-dd"
  final String createdAt;

  HealthSchedule({
    this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.scheduleType,
    required this.scheduledTime,
    this.repeatType = 'Hàng ngày',
    this.isCompleted = false,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'schedule_type': scheduleType,
      'scheduled_time': scheduledTime,
      'repeat_type': repeatType,
      'is_completed': isCompleted ? 1 : 0,
      'date': date,
      'created_at': createdAt,
    };
  }

  factory HealthSchedule.fromMap(Map<String, dynamic> map) {
    return HealthSchedule(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      scheduleType: (map['schedule_type'] as String?) ?? 'Khác',
      scheduledTime: (map['scheduled_time'] as String?) ?? '08:00',
      repeatType: (map['repeat_type'] as String?) ?? 'Hàng ngày',
      isCompleted: (map['is_completed'] as int?) == 1,
      date: (map['date'] as String?) ?? '',
      createdAt: (map['created_at'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  HealthSchedule copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? scheduleType,
    String? scheduledTime,
    String? repeatType,
    bool? isCompleted,
    String? date,
    String? createdAt,
  }) {
    return HealthSchedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      repeatType: repeatType ?? this.repeatType,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Icon helper theo loại lịch trình
  IconData get icon {
    switch (scheduleType) {
      case 'Uống nước':
        return Icons.water_drop_rounded;
      case 'Tập luyện':
        return Icons.fitness_center_rounded;
      case 'Ăn uống':
        return Icons.restaurant_rounded;
      case 'Ngủ':
        return Icons.bedtime_rounded;
      case 'Đo cân nặng':
        return Icons.monitor_weight_rounded;
      default:
        return Icons.alarm_rounded;
    }
  }

  // Color helper theo loại lịch trình
  Color get color {
    switch (scheduleType) {
      case 'Uống nước':
        return const Color(0xFF0A84FF); // Blue
      case 'Tập luyện':
        return const Color(0xFFFF375F); // Red
      case 'Ăn uống':
        return const Color(0xFFFF9F0A); // Orange
      case 'Ngủ':
        return const Color(0xFFBF5AF2); // Purple
      case 'Đo cân nặng':
        return const Color(0xFF5AC8FA); // Teal
      default:
        return const Color(0xFF32D74B); // Green
    }
  }
}

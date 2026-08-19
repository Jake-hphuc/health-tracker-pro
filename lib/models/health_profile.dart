class HealthProfile {
  final int? id;
  final int userId;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final double height;
  final double currentWeight;
  final double targetWeight;
  final String healthGoal;
  final String activityLevel;
  final int waterGoal;
  final double sleepGoal;
  final String createdAt;
  final String updatedAt;

  HealthProfile({
    this.id,
    required this.userId,
    required this.fullName,
    this.dateOfBirth = '2000-01-01',
    this.gender = 'Nam',
    required this.height,
    this.currentWeight = 65.0,
    this.targetWeight = 60.0,
    this.healthGoal = 'Duy trì vóc dáng',
    this.activityLevel = 'Vừa phải',
    this.waterGoal = 2000,
    this.sleepGoal = 8.0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'height': height,
      'current_weight': currentWeight,
      'target_weight': targetWeight,
      'health_goal': healthGoal,
      'activity_level': activityLevel,
      'water_goal': waterGoal,
      'sleep_goal': sleepGoal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    return HealthProfile(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      fullName: (map['full_name'] as String?) ?? 'Người dùng',
      dateOfBirth: (map['date_of_birth'] as String?) ?? '2000-01-01',
      gender: (map['gender'] as String?) ?? 'Nam',
      height: (map['height'] as num?)?.toDouble() ?? 170.0,
      currentWeight: (map['current_weight'] as num?)?.toDouble() ?? 65.0,
      targetWeight: (map['target_weight'] as num?)?.toDouble() ?? 60.0,
      healthGoal: (map['health_goal'] as String?) ?? 'Duy trì vóc dáng',
      activityLevel: (map['activity_level'] as String?) ?? 'Vừa phải',
      waterGoal: (map['water_goal'] as int?) ?? 2000,
      sleepGoal: (map['sleep_goal'] as num?)?.toDouble() ?? 8.0,
      createdAt: (map['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      updatedAt: (map['updated_at'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  HealthProfile copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? dateOfBirth,
    String? gender,
    double? height,
    double? currentWeight,
    double? targetWeight,
    String? healthGoal,
    String? activityLevel,
    int? waterGoal,
    double? sleepGoal,
    String? createdAt,
    String? updatedAt,
  }) {
    return HealthProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      healthGoal: healthGoal ?? this.healthGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      waterGoal: waterGoal ?? this.waterGoal,
      sleepGoal: sleepGoal ?? this.sleepGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

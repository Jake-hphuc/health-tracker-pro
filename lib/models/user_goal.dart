class UserGoal {
  final int? id;
  final int userId;
  final int waterGoal; // ml
  final double sleepGoal; // hours
  final int activityGoal; // minutes

  UserGoal({
    this.id,
    required this.userId,
    required this.waterGoal,
    required this.sleepGoal,
    required this.activityGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'water_goal': waterGoal,
      'sleep_goal': sleepGoal,
      'activity_goal': activityGoal,
    };
  }

  factory UserGoal.fromMap(Map<String, dynamic> map) {
    return UserGoal(
      id: map['id'],
      userId: map['user_id'],
      waterGoal: map['water_goal'],
      sleepGoal: (map['sleep_goal'] as num).toDouble(),
      activityGoal: map['activity_goal'],
    );
  }
}

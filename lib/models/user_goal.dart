/// Model má»¥c tiĂªu sá»©c khá»e cĂ¡ nhĂ¢n
class UserGoal {
  final int? id;
  final int userId;
  final int waterGoal;    // ml (máº·c Ä‘á»‹nh 2000)
  final double sleepGoal; // giá» (máº·c Ä‘á»‹nh 8.0)
  final double weightGoal;// kg
  final int activityGoal; // phĂºt/ngĂ y (máº·c Ä‘á»‹nh 30)

  UserGoal({
    this.id,
    required this.userId,
    this.waterGoal = 2000,
    this.sleepGoal = 8.0,
    this.weightGoal = 65.0,
    this.activityGoal = 30,
  });

  factory UserGoal.fromMap(Map<String, dynamic> map) {
    return UserGoal(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      waterGoal: map['water_goal'] as int,
      sleepGoal: (map['sleep_goal'] as num).toDouble(),
      weightGoal: (map['weight_goal'] as num).toDouble(),
      activityGoal: map['activity_goal'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'water_goal': waterGoal,
      'sleep_goal': sleepGoal,
      'weight_goal': weightGoal,
      'activity_goal': activityGoal,
    };
  }
}


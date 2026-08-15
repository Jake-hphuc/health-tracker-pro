class ActivityRecord {
  final int? id;
  final int userId;
  final String type;
  final int duration; // minutes
  final double calories;
  final String date;

  ActivityRecord({
    this.id,
    required this.userId,
    required this.type,
    required this.duration,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'duration': duration,
      'calories': calories,
      'date': date,
    };
  }

  factory ActivityRecord.fromMap(Map<String, dynamic> map) {
    return ActivityRecord(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      duration: map['duration'],
      calories: (map['calories'] as num).toDouble(),
      date: map['date'],
    );
  }
}

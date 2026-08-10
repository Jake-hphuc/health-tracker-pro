/// Model ghi nháº­n váº­n Ä‘á»™ng thá»ƒ cháº¥t
class ActivityRecord {
  final int? id;
  final int userId;
  final String type;     // Äi bá»™, Cháº¡y bá»™, Äáº¡p xe, BÆ¡i lá»™i, Gym, Yoga, KhĂ¡c
  final int duration;    // PhĂºt
  final double distance; // km (náº¿u cĂ³)
  final int calories;    // Æ¯á»›c tĂ­nh
  final String date;     // yyyy-MM-dd

  ActivityRecord({
    this.id,
    required this.userId,
    required this.type,
    required this.duration,
    required this.distance,
    required this.calories,
    required this.date,
  });

  factory ActivityRecord.fromMap(Map<String, dynamic> map) {
    return ActivityRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      type: map['type'] as String,
      duration: map['duration'] as int,
      distance: (map['distance'] as num).toDouble(),
      calories: map['calories'] as int,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'type': type,
      'duration': duration,
      'distance': distance,
      'calories': calories,
      'date': date,
    };
  }
}


class SleepRecord {
  final int? id;
  final int userId;
  final String sleepTime;
  final String wakeTime;
  final double duration; // hours
  final String quality;
  final String date;

  SleepRecord({
    this.id,
    required this.userId,
    required this.sleepTime,
    required this.wakeTime,
    required this.duration,
    required this.quality,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'sleep_time': sleepTime,
      'wake_time': wakeTime,
      'duration': duration,
      'quality': quality,
      'date': date,
    };
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'],
      userId: map['user_id'],
      sleepTime: map['sleep_time'],
      wakeTime: map['wake_time'],
      duration: (map['duration'] as num).toDouble(),
      quality: map['quality'],
      date: map['date'],
    );
  }
}

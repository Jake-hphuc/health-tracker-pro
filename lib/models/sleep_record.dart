/// Model ghi nháº­n giáº¥c ngá»§
class SleepRecord {
  final int? id;
  final int userId;
  final String sleepTime; // HH:mm hoáº·c ISO
  final String wakeTime;  // HH:mm hoáº·c ISO
  final double duration;  // Sá»‘ giá» ngá»§ (vd: 7.5)
  final String quality;   // Tá»‘t, Trung bĂ¬nh, KĂ©m
  final String date;      // yyyy-MM-dd

  SleepRecord({
    this.id,
    required this.userId,
    required this.sleepTime,
    required this.wakeTime,
    required this.duration,
    required this.quality,
    required this.date,
  });

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      sleepTime: map['sleep_time'] as String,
      wakeTime: map['wake_time'] as String,
      duration: (map['duration'] as num).toDouble(),
      quality: map['quality'] as String,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'sleep_time': sleepTime,
      'wake_time': wakeTime,
      'duration': duration,
      'quality': quality,
      'date': date,
    };
  }
}


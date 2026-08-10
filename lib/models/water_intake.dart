/// Model ghi nháº­n lÆ°á»£ng nÆ°á»›c uá»‘ng
class WaterIntake {
  final int? id;
  final int userId;
  final int amount; // ml
  final String date; // yyyy-MM-dd
  final String time; // HH:mm

  WaterIntake({
    this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.time,
  });

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      amount: map['amount'] as int,
      date: map['date'] as String,
      time: map['time'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'amount': amount,
      'date': date,
      'time': time,
    };
  }
}


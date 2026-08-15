class WaterIntake {
  final int? id;
  final int userId;
  final int amount; // ml
  final String time;
  final String date;

  WaterIntake({
    this.id,
    required this.userId,
    required this.amount,
    required this.time,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'time': time,
      'date': date,
    };
  }

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'],
      userId: map['user_id'],
      amount: map['amount'],
      time: map['time'],
      date: map['date'],
    );
  }
}

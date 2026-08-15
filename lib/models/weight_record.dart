class WeightRecord {
  final int? id;
  final int userId;
  final double weight;
  final double bmi;
  final String date;

  WeightRecord({
    this.id,
    required this.userId,
    required this.weight,
    required this.bmi,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'bmi': bmi,
      'date': date,
    };
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'],
      userId: map['user_id'],
      weight: (map['weight'] as num).toDouble(),
      bmi: (map['bmi'] as num).toDouble(),
      date: map['date'],
    );
  }
}

/// Model ghi nháº­n cĂ¢n náº·ng vĂ  BMI
class WeightRecord {
  final int? id;
  final int userId;
  final double weight; // kg
  final double bmi;    // Chá»‰ sá»‘ BMI tá»± tĂ­nh
  final String date;   // yyyy-MM-dd

  WeightRecord({
    this.id,
    required this.userId,
    required this.weight,
    required this.bmi,
    required this.date,
  });

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      weight: (map['weight'] as num).toDouble(),
      bmi: (map['bmi'] as num).toDouble(),
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'weight': weight,
      'bmi': bmi,
      'date': date,
    };
  }
}


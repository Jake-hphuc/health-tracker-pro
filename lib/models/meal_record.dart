class MealRecord {
  final int? id;
  final int userId;
  final String name;
  final int calories;
  final double protein; // grams
  final double carbs;   // grams
  final double fat;     // grams
  final String mealType; // 'Bữa Sáng', 'Bữa Trưa', 'Bữa Tối', 'Ăn Vặt'
  final String photoEmoji;
  final String time;
  final String date;

  MealRecord({
    this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.photoEmoji,
    required this.time,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'meal_type': mealType,
      'photo_emoji': photoEmoji,
      'time': time,
      'date': date,
    };
  }

  factory MealRecord.fromMap(Map<String, dynamic> map) {
    return MealRecord(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      calories: map['calories'],
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      mealType: map['meal_type'],
      photoEmoji: map['photo_emoji'] ?? '🍽️',
      time: map['time'] ?? '12:00',
      date: map['date'],
    );
  }
}

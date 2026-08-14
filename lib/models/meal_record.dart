class MealRecord {
  final int? id;
  final int userId;
  final String name;
  final String mealType; // Bua sang, Bua trua, Bua toi, Bua phu
  final int calories; // kcal
  final double protein; // g
  final double carbs; // g
  final double fat; // g
  final String? imagePath;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm

  MealRecord({
    this.id,
    required this.userId,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imagePath,
    required this.date,
    required this.time,
  });

  factory MealRecord.fromMap(Map<String, dynamic> map) {
    return MealRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      mealType: map['meal_type'] as String,
      calories: map['calories'] as int,
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      imagePath: map['image_path'] as String?,
      date: map['date'] as String,
      time: map['time'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'meal_type': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'image_path': imagePath,
      'date': date,
      'time': time,
    };
  }
}
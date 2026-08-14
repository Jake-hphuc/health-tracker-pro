/// Tiện ích tính chỉ số BMI (Body Mass Index) và Năng Lượng Đốt Cháy
class BMICalculator {
  /// Tính BMI từ cân nặng (kg) và chiều cao (cm)
  ///
  /// Công thức: BMI = weight / (height_in_meters)²
  static double calculate(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Ước tính calories đốt cháy dựa trên loại hoạt động và thời gian (kcal/phút)
  static int estimateCalories(String activityType, int durationMinutes) {
    const caloriesPerMinute = {
      'Đi bộ': 4.5,
      'Chạy bộ': 10.5,
      'Đạp xe': 8.0,
      'Tập tạ': 6.5,
      'Yoga': 3.5,
      'HIIT': 12.0,
      'Leo núi': 9.0,
      'Bơi lội': 9.5,
      'Bóng rổ': 8.5,
      'Bóng đá': 9.0,
      'Cầu lông': 7.5,
      'Gym': 6.5,
      'Khác': 5.0,
    };
    final rate = caloriesPerMinute[activityType] ?? 5.5;
    return (rate * durationMinutes).round();
  }

  /// Đánh giá phân loại BMI chuẩn WHO
  static String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 24.9) return 'Bình thường';
    if (bmi < 29.9) return 'Thừa cân';
    return 'Béo phì';
  }
}

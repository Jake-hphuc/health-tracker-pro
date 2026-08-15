/// Utility class for calculating and categorizing BMI (Body Mass Index).
/// 
/// BMI is calculated as: weight (kg) / (height (m))²
/// 
/// Categories:
/// - Underweight: < 18.5
/// - Normal: 18.5 - 24.9
/// - Overweight: 25.0 - 29.9
/// - Obese: ≥ 30.0
class BmiCalculator {
  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String getBmiCategory(double bmi) {
    if (bmi <= 0) return 'Chưa có dữ liệu';
    if (bmi < 18.5) return 'Gầy / Thiếu cân';
    if (bmi < 23.0) return 'Bình thường / Chuẩn';
    if (bmi < 25.0) return 'Tiền béo phì';
    if (bmi < 30.0) return 'Béo phì độ I';
    return 'Béo phì độ II';
  }

  static int getBmiColor(double bmi) {
    if (bmi <= 0) return 0xFF8E8E93;
    if (bmi < 18.5) return 0xFF0A84FF; // Blue
    if (bmi < 23.0) return 0xFF32D74B; // Green
    if (bmi < 25.0) return 0xFFFFD60A; // Yellow
    if (bmi < 30.0) return 0xFFFF9F0A; // Orange
    return 0xFFFF375F; // Red
  }

  static double calculateCaloriesBurned(String activityType, int durationMinutes, double weightKg) {
    // MET values (Metabolic Equivalent of Task)
    double met = 4.0;
    switch (activityType) {
      case 'Đi bộ':
        met = 3.5;
        break;
      case 'Chạy bộ':
        met = 9.8;
        break;
      case 'Đạp xe':
        met = 7.5;
        break;
      case 'Bơi lội':
        met = 8.0;
        break;
      case 'Tập tạ':
      case 'Gym':
        met = 5.5;
        break;
      case 'Yoga':
        met = 3.0;
        break;
      case 'HIIT':
        met = 11.0;
        break;
      case 'Leo núi':
        met = 8.5;
        break;
      case 'Bóng rổ':
        met = 8.0;
        break;
      case 'Bóng đá':
        met = 9.0;
        break;
      case 'Cầu lông':
        met = 6.0;
        break;
      default:
        met = 4.5;
    }

    // Calories = MET * Weight(kg) * Duration(hours)
    return met * weightKg * (durationMinutes / 60.0);
  }
}

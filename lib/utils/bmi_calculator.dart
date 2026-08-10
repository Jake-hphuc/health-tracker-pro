/// Tiá»‡n Ă­ch tĂ­nh chá»‰ sá»‘ BMI (Body Mass Index)
class BMICalculator {
  /// TĂ­nh BMI tá»« cĂ¢n náº·ng (kg) vĂ  chiá»u cao (cm)
  ///
  /// CĂ´ng thá»©c: BMI = weight / (height_in_meters)Â²
  static double calculate(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Æ¯á»›c tĂ­nh calories Ä‘á»‘t chĂ¡y dá»±a trĂªn loáº¡i hoáº¡t Ä‘á»™ng vĂ  thá»i gian
  static int estimateCalories(String activityType, int durationMinutes) {
    const caloriesPerMinute = {
      'Äi bá»™': 4.0,
      'Cháº¡y bá»™': 10.0,
      'Äáº¡p xe': 7.5,
      'BÆ¡i lá»™i': 8.0,
      'Gym': 6.0,
      'Yoga': 3.0,
      'KhĂ¡c': 5.0,
    };
    final rate = caloriesPerMinute[activityType] ?? 5.0;
    return (rate * durationMinutes).round();
  }
}


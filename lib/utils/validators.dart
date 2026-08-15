/// Validation helper class for input validation.
/// 
/// Provides static methods to validate various user inputs like
/// email, password, height, weight, and other health metrics.
class Validators {
  /// Validates email format using regex pattern.
  /// 
  /// [email] The email address to validate.
  /// Returns true if email format is valid, false otherwise.
  /// 
  /// Example:
  /// ```dart
  /// if (!Validators.isValidEmail(email)) {
  ///   return 'Email không hợp lệ';
  /// }
  /// ```
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validates password strength.
  /// 
  /// Requirements:
  /// - Minimum 6 characters
  /// - At least one uppercase letter
  /// - At least one number
  /// 
  /// [password] The password to validate.
  /// Returns true if password meets strength requirements.
  static bool isStrongPassword(String password) {
    if (password.isEmpty || password.length < 6) return false;
    
    // Check for at least one uppercase letter
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    // Check for at least one number
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    
    return hasUppercase && hasNumber;
  }
  
  /// Validates height in centimeters.
  /// 
  /// Valid range: 100 - 250 cm
  /// 
  /// [height] The height value to validate.
  /// Returns true if height is within valid range.
  static bool isValidHeight(double height) {
    return height >= 100 && height <= 250;
  }
  
  /// Validates weight in kilograms.
  /// 
  /// Valid range: 30 - 300 kg
  /// 
  /// [weight] The weight value to validate.
  /// Returns true if weight is within valid range.
  static bool isValidWeight(double weight) {
    return weight >= 30 && weight <= 300;
  }
  
  /// Validates water intake amount in milliliters.
  /// 
  /// Valid range: 100 - 2000 ml per intake
  /// 
  /// [amount] The water amount to validate.
  /// Returns true if amount is within valid range.
  static bool isValidWaterAmount(int amount) {
    return amount >= 100 && amount <= 2000;
  }
  
  /// Validates sleep duration in hours.
  /// 
  /// Valid range: 0 - 24 hours
  /// 
  /// [duration] The sleep duration to validate.
  /// Returns true if duration is within valid range.
  static bool isValidSleepDuration(double duration) {
    return duration >= 0 && duration <= 24;
  }
  
  /// Validates activity duration in minutes.
  /// 
  /// Valid range: 1 - 1440 minutes (24 hours)
  /// 
  /// [duration] The activity duration to validate.
  /// Returns true if duration is within valid range.
  static bool isValidActivityDuration(int duration) {
    return duration >= 1 && duration <= 1440;
  }
  
  /// Gets user-friendly error message for email validation.
  /// 
  /// [email] The email to validate.
  /// Returns null if valid, error message if invalid.
  static String? getEmailError(String email) {
    if (email.isEmpty) {
      return 'Email không được để trống';
    }
    if (!isValidEmail(email)) {
      return 'Email không hợp lệ. Vui lòng nhập đúng định dạng email';
    }
    return null;
  }
  
  /// Gets user-friendly error message for password validation.
  /// 
  /// [password] The password to validate.
  /// Returns null if valid, error message if invalid.
  static String? getPasswordError(String password) {
    if (password.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ cái viết hoa';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }
    return null;
  }
  
  /// Gets user-friendly error message for height validation.
  /// 
  /// [height] The height to validate.
  /// Returns null if valid, error message if invalid.
  static String? getHeightError(double? height) {
    if (height == null) {
      return 'Chiều cao không được để trống';
    }
    if (!isValidHeight(height)) {
      return 'Chiều cao phải trong khoảng 100-250 cm';
    }
    return null;
  }
  
  /// Gets user-friendly error message for weight validation.
  /// 
  /// [weight] The weight to validate.
  /// Returns null if valid, error message if invalid.
  static String? getWeightError(double? weight) {
    if (weight == null) {
      return 'Cân nặng không được để trống';
    }
    if (!isValidWeight(weight)) {
      return 'Cân nặng phải trong khoảng 30-300 kg';
    }
    return null;
  }
}

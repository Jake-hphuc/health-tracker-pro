import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Helper class for security operations like password hashing.
/// 
/// Uses SHA-256 algorithm to hash passwords before storing in database.
/// This ensures passwords are never stored in plain text.
class SecurityHelper {
  /// Hashes a password using SHA-256 algorithm.
  /// 
  /// [password] The plain text password to hash.
  /// Returns the hashed password as a hexadecimal string.
  /// 
  /// Example:
  /// ```dart
  /// final hashed = SecurityHelper.hashPassword('myPassword123');
  /// // Returns: "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f"
  /// ```
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Verifies if a plain text password matches a hashed password.
  /// 
  /// [password] The plain text password to verify.
  /// [hashedPassword] The hashed password to compare against.
  /// Returns true if the password matches, false otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final isValid = SecurityHelper.verifyPassword('myPassword123', hashedPassword);
  /// if (isValid) {
  ///   print('Password is correct!');
  /// }
  /// ```
  static bool verifyPassword(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }
}

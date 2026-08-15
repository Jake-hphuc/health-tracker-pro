/// Represents a user in the Health Tracker Pro application.
/// 
/// Contains user profile information including:
/// - Authentication credentials (email, hashed password)
/// - Personal information (name, height)
/// - Role (admin flag)
/// 
/// Passwords should always be hashed using SecurityHelper before storing.
class User {
  final int? id;
  final String name;
  final String email;
  final String password; // Should be hashed with SHA-256
  final double height; // in centimeters
  final bool isAdmin;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.height,
    this.isAdmin = false,
  });

  /// Converts User object to Map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'height': height,
      'is_admin': isAdmin ? 1 : 0,
    };
  }

  /// Creates User object from database Map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      height: (map['height'] as num).toDouble(),
      isAdmin: (map['is_admin'] == 1 || map['isAdmin'] == true),
    );
  }
}

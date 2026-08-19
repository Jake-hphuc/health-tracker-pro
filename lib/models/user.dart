class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final double height; // cm
  final bool isAdmin;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.height,
    this.isAdmin = false,
  });

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

/// Model ngÆ°á»i dĂ¹ng
class User {
  final int? id;
  final String name;
  final String email;
  final String password; // SHA256 hash
  final double height; // cm
  final String createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.height,
    required this.createdAt,
  });

  /// Chuyá»ƒn Ä‘á»•i tá»« Map (SQLite) sang User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      height: (map['height'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }

  /// Chuyá»ƒn Ä‘á»•i User object sang Map (Ä‘á»ƒ insert vĂ o SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'height': height,
      'created_at': createdAt,
    };
  }

  /// Táº¡o báº£n sao vá»›i má»™t sá»‘ trÆ°á»ng Ä‘Æ°á»£c thay Ä‘á»•i
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    double? height,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


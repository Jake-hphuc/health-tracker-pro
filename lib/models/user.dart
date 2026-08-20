class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final double height; // cm
  final bool isAdmin;
  final bool isLocked;
  final String createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.height,
    this.isAdmin = false,
    this.isLocked = false,
    String? createdAt,
  }) : createdAt = createdAt ?? '20/08/2026';

  String get status => isLocked ? 'Khóa' : 'Hoạt động';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'height': height,
      'is_admin': isAdmin ? 1 : 0,
      'is_locked': isLocked ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? 'Người dùng',
      email: (map['email'] as String?) ?? '',
      password: (map['password'] as String?) ?? '',
      height: (map['height'] as num?)?.toDouble() ?? 170.0,
      isAdmin: (map['is_admin'] == 1 || map['isAdmin'] == true),
      isLocked: (map['is_locked'] == 1 || map['isLocked'] == true),
      createdAt: (map['created_at'] as String?) ?? '20/08/2026',
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    double? height,
    bool? isAdmin,
    bool? isLocked,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      height: height ?? this.height,
      isAdmin: isAdmin ?? this.isAdmin,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

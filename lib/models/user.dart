class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final double height;
  final String createdAt;
  final bool isAdmin;

  User({this.id, required this.name, required this.email, required this.password, required this.height, required this.createdAt, this.isAdmin = false});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'] as int?, name: map['name'] as String, email: map['email'] as String, password: map['password'] as String, height: (map['height'] as num).toDouble(), createdAt: map['created_at'] as String, isAdmin: (map['is_admin'] as int? ?? 0) == 1);
  }

  Map<String, dynamic> toMap() {
    return {if (id != null) 'id': id, 'name': name, 'email': email, 'password': password, 'height': height, 'created_at': createdAt, 'is_admin': isAdmin ? 1 : 0};
  }

  User copyWith({int? id, String? name, String? email, String? password, double? height, String? createdAt, bool? isAdmin}) {
    return User(id: id ?? this.id, name: name ?? this.name, email: email ?? this.email, password: password ?? this.password, height: height ?? this.height, createdAt: createdAt ?? this.createdAt, isAdmin: isAdmin ?? this.isAdmin);
  }
}
class UserModel {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final bool isActive;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.isActive = true,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullName: map['fullName'],
      email: map['email'],
      phone: map['phone'],
      role: map['role'],
      isActive: map['isActive'] == 1,
      avatarPath: map['avatarPath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive ? 1 : 0,
      'avatarPath': avatarPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isKasir => role == 'kasir';
}

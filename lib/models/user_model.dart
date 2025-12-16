// lib/models/user_model.dart
class AppUser {
  final int id;
  final String username;
  final String? image;
  final int? age;
  final int? gender;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    this.image,
    this.age,
    this.gender,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      username: json['username'] as String,
      image: json['image'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'image': image,
      'age': age,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
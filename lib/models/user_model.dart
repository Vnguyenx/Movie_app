import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final String role;
  final String phone;
  final DateTime? bannedUntil;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.role,
    this.phone = '',
    this.bannedUntil,
    required this.createdAt,
    this.updatedAt,
  });

  String get safeName {
    if (displayName.trim().isNotEmpty) return displayName;
    return email.split('@')[0];
  }

  bool get isBanned {
    if (bannedUntil == null) return false;
    return bannedUntil!.isAfter(DateTime.now());
  }

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? data['photoUrl'] ?? data['avatar'] ?? '',
      role: data['role'] ?? 'user',

      // --- CÁC TRƯỜNG MỚI ---
      phone: data['phoneNumber'] ?? data['phone'] ?? '', // Lấy sđt
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(), // Lấy ngày update

      bannedUntil: (data['bannedUntil'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

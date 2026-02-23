import 'package:cloud_firestore/cloud_firestore.dart';

class InteractionModel {
  final String id;
  final String userId;
  final String movieId;
  final String type; // 'rating' hoặc 'comment'
  final String content;
  final double ratingValue;
  final DateTime createdAt;

  InteractionModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.type,
    this.content = '',
    this.ratingValue = 0,
    required this.createdAt,
  });

  // Factory chuyển đổi từ Firestore Document -> Object Dart
  factory InteractionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // --- LOGIC ĐỒNG BỘ VỚI ADMIN ---
    // Xử lý logic điểm số: hệ 5 -> hệ 10
    double rawRating = (data['value'] ?? 0).toDouble();

    // Nếu dữ liệu cũ lưu hệ 5 (<= 5) thì nhân đôi lên thành hệ 10
    if (rawRating > 0 && rawRating <= 5) {
      rawRating = rawRating * 2;
    }

    return InteractionModel(
      id: doc.id,
      userId: data['userId'] ?? 'anonymous',
      movieId: data['movieId'] ?? '',
      type: data['type'] ?? 'comment',
      content: data['content'] ?? '',
      // Xử lý an toàn cho rating
      ratingValue: rawRating,
      // Xử lý an toàn cho ngày tháng
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển Object -> Map để lưu lên Firestore (Dùng khi User comment)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'movieId': movieId,
      'type': type,
      'content': content,
      'value': ratingValue,
      'createdAt': FieldValue.serverTimestamp(), // Lấy giờ server
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/interaction_model.dart';

class InteractionController {
  final CollectionReference _ref =
      FirebaseFirestore.instance.collection('interactions');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. GỬI BÌNH LUẬN / ĐÁNH GIÁ (Dành cho User)
  Future<void> addInteraction({
    required String movieId,
    required String content,
    double rating = 0,
    String type = 'comment',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Bạn cần đăng nhập để bình luận");

    try {
      // Tạo data map
      final data = {
        'userId': user.uid,
        'movieId': movieId,
        'type': type,
        'content': content,
        'value': rating,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _ref.add(data);
    } catch (e) {
      print("Lỗi gửi bình luận: $e");
      rethrow;
    }
  }

  // 2. LẤY DANH SÁCH BÌNH LUẬN (Real-time Stream)
  Stream<List<InteractionModel>> getInteractionsStream(String movieId) {
    return _ref
        .where('movieId', isEqualTo: movieId) // Chỉ lấy của phim này
        .orderBy('createdAt', descending: true) // Mới nhất lên đầu
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InteractionModel.fromSnapshot(doc))
            .toList());
  }
}

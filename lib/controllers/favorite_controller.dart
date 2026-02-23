import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model.dart';

class FavoriteController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. LẤY DANH SÁCH (Đã sửa để khớp fromMap mới) ---
  Stream<List<MovieModel>> getFavoritesStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // 🔥 QUAN TRỌNG: Truyền data VÀ doc.id vào hàm fromMap
        return MovieModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // --- 2. KIỂM TRA ĐÃ LIKE CHƯA ---
  Stream<bool> isFavoriteStream(String movieId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(movieId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // --- 3. THÊM / XÓA (CÓ KIỂM TRA ĐĂNG NHẬP) ---
  Future<bool> toggleFavorite(MovieModel movie) async {
    final user = _auth.currentUser;

    // 👉 CHƯA ĐĂNG NHẬP
    if (user == null) {
      return false;
    }

    final favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(movie.id);

    final doc = await favoriteRef.get();

    if (doc.exists) {
      // XÓA
      await favoriteRef.delete();
    } else {
      // THÊM
      final data = movie.toMap();
      data['addedAt'] = FieldValue.serverTimestamp();
      await favoriteRef.set(data);
    }

    return true;
  }
}

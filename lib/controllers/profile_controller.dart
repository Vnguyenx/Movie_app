import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Lấy thông tin User hiện tại
  Future<UserModel?> getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
    } catch (e) {
      print("Lỗi lấy user: $e");
    }
    return null;
  }

  // 2. Cập nhật thông tin (Logic quan trọng ở đây)
  Future<String?> updateUserProfile({
    required String uid,
    required String displayName,
    required String photoURL,
    required String phone,
  }) async {
    try {
      // A. Cập nhật Auth (Để hiển thị hệ thống cập nhật ngay)
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        if (displayName.isNotEmpty)
          await currentUser.updateDisplayName(displayName);
        if (photoURL.isNotEmpty) await currentUser.updatePhotoURL(photoURL);
      }

      // B. Cập nhật Firestore
      await _firestore.collection('users').doc(uid).update({
        'displayName': displayName,
        'photoURL': photoURL,
        'phone': phone, // Lưu ý: Model bạn dùng tên biến là 'phone'

        // 🔥 TỰ ĐỘNG CẬP NHẬT THỜI GIAN
        // FieldValue.serverTimestamp() lấy giờ chuẩn của server Google
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh lại Auth để đồng bộ
      await currentUser?.reload();

      return null; // Không có lỗi
    } catch (e) {
      return "Lỗi cập nhật: $e";
    }
  }

  // 3. Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<UserModel?> getCurrentUserStream() {
    final User? currentUser = _auth.currentUser;
    // Nếu chưa đăng nhập thì trả về null
    if (currentUser == null) return Stream.value(null);

    // Lắng nghe thay đổi thời gian thực tại document của user này
    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      // Chuyển đổi dữ liệu từ Firestore sang UserModel
      return UserModel.fromSnapshot(snapshot);
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';

class UserChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy User ID hiện tại (Bắt buộc user phải đăng nhập)
  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? 'user@test.com';

  // 1. Gửi tin nhắn (User gửi -> Admin)
  Future<void> sendMessage(String text) async {
    if (currentUserId.isEmpty || text.trim().isEmpty) return;

    final timestamp = FieldValue.serverTimestamp();

    // A. Thêm tin nhắn vào sub-collection
    await _firestore
        .collection('chats')
        .doc(currentUserId)
        .collection('messages')
        .add({
      'text': text,
      'isAdmin': false, // Quan trọng: Đây là tin nhắn của User
      'createdAt': timestamp,
    });

    // B. Cập nhật thông tin phòng chat bên ngoài
    // Lưu ý: reset unreadAdminCount = 1 để báo Admin có tin mới (nếu Admin có làm tính năng đó)
    await _firestore.collection('chats').doc(currentUserId).set({
      'userEmail': currentUserEmail,
      'lastMessage': text,
      'lastTime': timestamp,
      'unreadAdminCount': FieldValue.increment(1),
      'unreadUserCount':
          0, // Reset số tin chưa đọc của User về 0 vì User vừa nhắn
    }, SetOptions(merge: true)); // merge: true để không ghi đè mất dữ liệu cũ
  }

  // 2. Lấy luồng tin nhắn
  Stream<List<ChatMessage>> getMessagesStream() {
    if (currentUserId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('chats')
        .doc(currentUserId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromSnapshot(doc)).toList());
  }

  // 3. Đánh dấu đã đọc (Gọi khi User mở màn hình chat)
  Future<void> markAsRead() async {
    if (currentUserId.isEmpty) return;

    // Cập nhật trường unreadUserCount = 0 trong document cha
    await _firestore.collection('chats').doc(currentUserId).update({
      'unreadUserCount': 0,
    }).catchError((e) {
      // Bỏ qua lỗi nếu document chưa tồn tại
    });
  }

  // 4. Stream đếm số tin nhắn chưa đọc (Để hiển thị ở BottomBar)
  Stream<int> getUnreadCountStream() {
    if (currentUserId.isEmpty) return Stream.value(0);

    return _firestore
        .collection('chats')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>;
      // Trả về số lượng tin Admin nhắn mà User chưa đọc
      return (data['unreadUserCount'] ?? 0) as int;
    });
  }
}

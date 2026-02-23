import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Xử lý Đăng ký
  Future<String?> handleRegister({
    required String email,
    required String password,
    required String confirmPassword,
    required String username,
  }) async {
    // 1. Kiểm tra logic cơ bản (Validate)
    if (password != confirmPassword) {
      return "Mật khẩu nhập lại không khớp!";
    }
    if (password.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự.";
    }

    try {
      // 2. Tạo tài khoản trên Firebase Auth (Két sắt bảo mật)
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Lưu thông tin bổ sung vào Firestore collection 'users'
      await _db.collection('users').doc(credential.user!.uid).set({
        'username': username,
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      return e.message; // Trả về lỗi từ Firebase (VD: Email đã tồn tại)
    }
  }

  // Xử lý Đăng nhập
  Future<String?> handleLogin(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return "Sai email hoặc mật khẩu!";
    }
  }

  // Đăng xuất
  Future<void> handleLogout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Ném lỗi ra để UI bắt và hiển thị
      if (e.code == 'user-not-found') {
        throw 'Email này chưa đăng ký tài khoản.';
      } else if (e.code == 'invalid-email') {
        throw 'Định dạng email không hợp lệ.';
      } else {
        throw 'Lỗi: ${e.message}';
      }
    } catch (e) {
      throw 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
  }
}

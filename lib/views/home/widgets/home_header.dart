import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/profile_controller.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';

class HomeHeader extends StatelessWidget {
  HomeHeader({super.key});

  // 1. Gọi Controller để lấy luồng dữ liệu
  final ProfileController _profileController = ProfileController();

  @override
  Widget build(BuildContext context) {
    // 2. Bọc toàn bộ UI trong StreamBuilder để "nghe" dữ liệu
    return StreamBuilder<UserModel?>(
      stream: _profileController.getCurrentUserStream(),
      builder: (context, snapshot) {
        // --- XỬ LÝ DỮ LIỆU ---
        String displayName = "Khách";
        String? photoURL;
        final currentUser = FirebaseAuth.instance.currentUser;

        if (snapshot.hasData && snapshot.data != null) {
          // Ưu tiên 1: Dữ liệu realtime từ Firestore (Vừa cập nhật xong)
          final userModel = snapshot.data!;
          displayName = userModel.displayName.isNotEmpty
              ? userModel.displayName
              : (currentUser?.displayName ?? "Bạn");
          photoURL = userModel.photoURL;
        } else {
          // Ưu tiên 2: Dữ liệu lưu tạm trong máy (Auth) nếu mạng chậm
          if (currentUser != null) {
            displayName = currentUser.displayName ?? "Bạn";
            photoURL = currentUser.photoURL;
          }
        }

        // --- GIAO DIỆN (UI) ---
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Nút Tìm kiếm
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.movieSearch);
                  },
                ),
              ),

              // 2. Lời chào
              Column(
                children: [
                  const Text("Xin chào,",
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(
                    displayName, // Biến này giờ sẽ tự nhảy số
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),

              // 3. Avatar
              GestureDetector(
                onTap: () {
                  if (currentUser == null) {
                    Navigator.pushNamed(context, AppRoutes.login);
                  } else {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  }
                },
                child: _buildAvatar(displayName, photoURL),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hàm vẽ Avatar tách ra cho gọn
  Widget _buildAvatar(String name, String? photoURL) {
    // A. Nếu có ảnh -> Hiển thị ảnh
    if (photoURL != null && photoURL.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent, // Nền trong suốt để ảnh đẹp hơn
        backgroundImage: NetworkImage(photoURL),
        // Thêm xử lý lỗi nếu link ảnh chết -> Hiện chữ cái đầu
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    // B. Nếu không có ảnh -> Hiển thị chữ cái đầu
    String firstLetter = (name.isNotEmpty) ? name[0].toUpperCase() : "U";

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.blueAccent,
      child: Text(firstLetter,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

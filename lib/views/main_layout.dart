import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import 'favorites/favorite_screen.dart';
import 'home/home_screen.dart';
import 'movies/movie_list_screen.dart';

// Import Controller và Screen Chat
import '../controllers/user_chat_controller.dart';
import '../views/chat/user_chat_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final UserChatController _chatController = UserChatController();

  // 1. CHỈ GIỮ LẠI 3 MÀN HÌNH CHÍNH (Bỏ ChatScreen ra khỏi đây)
  final List<Widget> _screens = [
    const HomeScreen(), // Index 0
    const MovieListScreen(), // Index 1
    const FavoriteScreen(), // Index 2
  ];

  // 🔥 HÀM XỬ LÝ LOGIC CHUYỂN TAB
  void _onTabChange(int index) {
    final user = FirebaseAuth.instance.currentUser;

    // --- TRƯỜNG HỢP ĐẶC BIỆT: NÚT CHAT (Index 3) ---
    // Chúng ta không chuyển tab, mà sẽ PUSH màn hình mới
    if (index == 3) {
      if (user == null) {
        _showLoginRequired();
        return;
      }

      // Đánh dấu đã đọc ngay khi bấm
      _chatController.markAsRead();

      // Mở màn hình Chat đè lên toàn bộ MainLayout
      // Khi push, thanh BottomBar sẽ bị che đi -> Giải quyết vấn đề của bạn
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserChatScreen()),
      ).then((_) {
        // (Tùy chọn) Khi quay lại, có thể làm mới gì đó nếu cần
      });

      return; // Dừng lại, không chạy logic set state bên dưới
    }

    // --- CÁC TAB BÌNH THƯỜNG (0, 1, 2) ---
    // Tab Yêu thích (Index 2) cần login
    if (index == 2 && user == null) {
      _showLoginRequired();
      return;
    }

    // Chuyển tab
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper hiển thị thông báo login
  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bạn cần đăng nhập để sử dụng tính năng này!"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 1),
      ),
    );
    Navigator.pushNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 1. Nội dung chính (Chỉ switch giữa Home, Movie, Fav)
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),

          // 2. Custom Floating Bottom Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: StreamBuilder<int>(
                    stream: _chatController.getUnreadCountStream(),
                    initialData: 0,
                    builder: (context, snapshot) {
                      int unreadCount = snapshot.data ?? 0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(Icons.home_rounded, 0),
                          _buildNavItem(Icons.movie_outlined, 1),
                          _buildNavItem(Icons.favorite_outline, 2),
                          // Nút Chat (Index 3) vẫn nằm đây để bấm
                          _buildNavItem(Icons.chat_bubble_outline, 3,
                              badgeCount: unreadCount),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper tạo icon
  Widget _buildNavItem(IconData icon, int index, {int badgeCount = 0}) {
    // Chỉ highlight nếu index trùng (Lưu ý: Index 3 Chat sẽ không bao giờ được highlight vì ta không set _selectedIndex = 3)
    bool isSelected = _selectedIndex == index;

    // Nếu muốn khi mở Chat về, icon Chat sáng lên 1 chút rồi tắt thì cần logic phức tạp hơn,
    // nhưng để đơn giản: Chat là nút action, không phải tab lưu trạng thái.

    return GestureDetector(
      onTap: () => _onTabChange(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF8B5CF6),
                shape: BoxShape.circle,
                boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2)
                  ])
            : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 24,
            ),
            if (badgeCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

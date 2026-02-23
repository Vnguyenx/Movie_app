import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Khai báo Controller text
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Khởi tạo AuthController
  final AuthController _authController = AuthController();

  // Biến trạng thái loading
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng nhập
  void _handleLogin() async {
    // 1. Ẩn bàn phím
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true; // Bật vòng quay loading
    });

    // 2. Gọi Controller xử lý
    String? error = await _authController.handleLogin(
        _emailController.text.trim(), _passController.text.trim());

    // Kiểm tra widget còn tồn tại không trước khi dùng context (tránh lỗi async)
    if (!mounted) return;

    setState(() {
      _isLoading = false; // Tắt vòng quay
    });

    if (error == null) {
      // --- LOGIC KHÁC BIỆT CỦA USER ---
      // Nếu đăng nhập thành công:
      // Ưu tiên 1: Đóng màn login để lộ ra màn hình cũ (Ví dụ: Đang ở Tab Yêu thích)
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        // Ưu tiên 2: Nếu không có gì để back, mới vào Home
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } else {
      // Hiện lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      // Appbar đơn giản để có nút Back/Close
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // Cho phép user thoát login nếu họ đổi ý (muốn xem phim tiếp mà ko cần login)
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.main);
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo hoặc Tiêu đề
              const Icon(Icons.movie_filter_outlined,
                  size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text("Chào mừng trở lại!",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Text("Đăng nhập để lưu phim yêu thích",
                  style: TextStyle(color: Colors.white54, fontSize: 14)),

              const SizedBox(height: 40),

              // Ô nhập Email
              CustomTextField(
                hint: "Email",
                icon: Icons.email_outlined,
                controller: _emailController,
              ),

              // Ô nhập Password
              CustomTextField(
                hint: "Mật Khẩu",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passController,
              ),

              // Link Quên mật khẩu
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: const Text("Quên Mật Khẩu?",
                      style: TextStyle(color: Colors.blueAccent)),
                ),
              ),

              const SizedBox(height: 20),

              // Nút Login (Có hiển thị Loading)
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(
                      16), // Bo tròn ít hơn chút cho hiện đại
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _handleLogin, // Disable khi đang load
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      )),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("Đăng Nhập",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 30),

              // Chuyển sang Đăng ký
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản? ",
                      style: TextStyle(color: Colors.white60)),
                  GestureDetector(
                    onTap: () {
                      // Chuyển sang màn hình đăng ký
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text("Đăng ký ngay",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

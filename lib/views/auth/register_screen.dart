import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Khai báo Controllers
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _rePassController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Khởi tạo AuthController
  final AuthController _authController = AuthController();

  // Biến trạng thái loading
  bool _isLoading = false;

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi thoát màn hình
    _userController.dispose();
    _passController.dispose();
    _rePassController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng ký
  void _handleRegister() async {
    // 1. Ẩn bàn phím
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true; // Bật loading
    });

    // 2. Gọi Controller
    String? error = await _authController.handleRegister(
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
      confirmPassword: _rePassController.text.trim(),
      username: _userController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false; // Tắt loading
    });

    if (error == null) {
      // --- LOGIC CỦA USER APP ---
      // Đăng ký thành công -> Xóa hết các màn hình cũ (Login/Intro...)
      // và đưa người dùng vào thẳng Trang chủ với tư cách thành viên mới.
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main,
          (route) => false // Điều kiện false nghĩa là xóa hết stack
          );

      // (Tùy chọn) Hiện thông báo chào mừng
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công! Chào mừng bạn."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Hiện lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      // Appbar để có nút Back quay lại Login nếu lỡ bấm nhầm
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Tạo Tài Khoản",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 10),
              const Text("Tham gia cộng đồng xem phim ngay hôm nay",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54)),

              const SizedBox(height: 40),

              CustomTextField(
                  hint: "Email",
                  icon: Icons.email_outlined,
                  controller: _emailController),
              CustomTextField(
                  hint: "Tên hiển thị (Username)",
                  icon: Icons.person_outline,
                  controller: _userController),
              CustomTextField(
                  hint: "Mật Khẩu",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passController),
              CustomTextField(
                  hint: "Nhập Lại Mật Khẩu",
                  icon: Icons.lock_reset,
                  isPassword: true,
                  controller: _rePassController),

              const SizedBox(height: 30),

              // Nút Register
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF2563EB)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ]),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                      : const Text("Đăng Ký",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Đã có tài khoản? ",
                      style: TextStyle(color: Colors.white60)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Quay lại Login
                    child: const Text("Đăng nhập",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

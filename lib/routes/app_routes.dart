import 'package:flutter/material.dart';

// --- IMPORT MODEL ĐỂ HIỂU DỮ LIỆU ---
import '../models/movie_model.dart'; // 🔥 Quan trọng: Phải import cái này

// --- CÁC VIEW ĐÃ HOÀN THIỆN ---
import '../views/main_layout.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/movies/movie_detail_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/movies/movie_search_screen.dart';

class AppRoutes {
  // --- ĐỊNH NGHĨA TÊN ROUTE ---
  static const String main = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String profile = '/profile';

  static const String movieSearch = '/movie_search';
  static const String movieDetail = '/movie_detail';

  // --- HÀM ĐIỀU HƯỚNG ---
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 1. Màn hình CHÍNH
      case main:
        return _fadeRoute(const MainLayout());

      // 2. AUTH (Đăng nhập/Đăng ký)
      case login:
        return _fadeRoute(const LoginScreen());
      case register:
        return _fadeRoute(const RegisterScreen());
      case forgotPassword:
        return _fadeRoute(const ForgotPasswordScreen());

      // 3. PROFILE
      case profile:
        return _fadeRoute(const ProfileScreen());

      // 4. TÌM KIẾM
      case movieSearch:
        return _fadeRoute(const SearchMovieScreen());

      // 5. CHI TIẾT PHIM (🔥 CẦN SỬA ĐOẠN NÀY)
      case movieDetail:
        // Kiểm tra xem arguments có phải là MovieModel không
        if (settings.arguments is MovieModel) {
          final movieArgs = settings.arguments as MovieModel;
          return _fadeRoute(MovieDetailScreen(movie: movieArgs));
        }
        // Nếu không có dữ liệu hoặc sai kiểu -> Báo lỗi
        return _errorRoute(settings.name);

      default:
        return _errorRoute(settings.name);
    }
  }

  // --- CÁC HÀM PHỤ TRỢ (Giữ nguyên) ---

  // Màn hình báo lỗi
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Lỗi điều hướng")),
        body: Center(
          child: Text(
            'Không tìm thấy màn hình: $routeName\nHoặc thiếu dữ liệu truyền vào.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  // Hiệu ứng Fade
  static PageRouteBuilder _fadeRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

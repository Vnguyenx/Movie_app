import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../../models/movie_model.dart';
import 'widgets/home_header.dart';
import 'widgets/hero_banner.dart';
import 'widgets/movie_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = HomeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        bottom: false,
        // Dùng StreamBuilder để lắng nghe dữ liệu thật
        child: StreamBuilder<List<MovieModel>>(
          stream: _controller.getMoviesStream(),
          builder: (context, snapshot) {
            // 1. Trạng thái đang tải
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Trạng thái có lỗi
            if (snapshot.hasError) {
              return Center(
                  child: Text("Lỗi: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white)));
            }

            // 3. Không có dữ liệu
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("Chưa có phim nào",
                      style: TextStyle(color: Colors.white)));
            }

            // 4. Có dữ liệu -> Phân loại để hiển thị
            final allMovies = snapshot.data!;

            // Logic hiển thị:
            // - Banner: Lấy 5 phim mới nhất
            final bannerMovies = allMovies.take(5).toList();

            // B. Trending (Hot):
// 1. Lọc phim có rating >= 7
            List<MovieModel> trendingMovies =
                allMovies.where((m) => m.rating >= 7.0).toList();

// 2. Sắp xếp giảm dần (Từ cao xuống thấp)
// Logic: So sánh rating của b với a. Nếu b > a thì b đứng trước.
            trendingMovies.sort((a, b) => b.rating.compareTo(a.rating));

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  HomeHeader(),

                  const SizedBox(height: 20),
                  // Truyền data thật vào Banner
                  HeroBanner(movies: bannerMovies),

                  const SizedBox(height: 20),
                  // Truyền data thật vào các Section
                  if (trendingMovies.isNotEmpty)
                    MovieSection(title: "Đánh giá cao", movies: trendingMovies),

                  // Mục tất cả phim
                  MovieSection(title: "Mới cập nhật", movies: allMovies),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

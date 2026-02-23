import 'package:flutter/material.dart';
import '../../controllers/favorite_controller.dart';
import '../../models/movie_model.dart';
import '../../widgets/movie_item.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteController _favController = FavoriteController();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Màu nền đồng bộ
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER & SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kho Phim Của Tôi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Thanh tìm kiếm
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value.toLowerCase();
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Tìm trong danh sách...",
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. LIST PHIM (GRID VIEW) ---
            Expanded(
              child: StreamBuilder<List<MovieModel>>(
                stream: _favController.getFavoritesStream(),
                builder: (context, snapshot) {
                  // Đang tải...
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allMovies = snapshot.data ?? [];

                  // Logic lọc phim theo thanh tìm kiếm
                  final displayedMovies = allMovies.where((movie) {
                    return movie.title.toLowerCase().contains(_searchText);
                  }).toList();

                  // Trường hợp 1: Chưa có phim nào trong Fav
                  if (allMovies.isEmpty) {
                    return _buildEmptyState(
                        "Chưa có phim yêu thích", Icons.favorite_border);
                  }

                  // Trường hợp 2: Có phim nhưng tìm không ra kết quả
                  if (displayedMovies.isEmpty) {
                    return _buildEmptyState(
                        "Không tìm thấy phim này", Icons.search_off);
                  }

                  // Trường hợp 3: Hiển thị lưới phim
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20,
                        100), // Padding dưới 100 để tránh BottomBar che
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 cột
                      childAspectRatio: 0.7, // Tỷ lệ khung hình (Poster dọc)
                      crossAxisSpacing: 15, // Khoảng cách ngang
                      mainAxisSpacing: 15, // Khoảng cách dọc
                    ),
                    itemCount: displayedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = displayedMovies[index];
                      // Ta bọc MovieItem trong LayoutBuilder để nó tự giãn theo Grid
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            // Ép width theo ô của Grid thay vì width 130 cố định của MovieItem cũ
                            width: double.infinity,
                            child: MovieItem(movie: movie),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị khi danh sách trống
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

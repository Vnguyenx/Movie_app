import 'package:flutter/material.dart';
import '../../controllers/movie_controller.dart';
import '../../models/movie_model.dart';
import '../../widgets/movie_item.dart';

/// MÀN HÌNH TÌM KIẾM PHIM
/// - Tìm trong Database trước
/// - Nếu không có, tìm trên TMDB (có trailer)
/// - User có thể thêm phim vào yêu thích
class SearchMovieScreen extends StatefulWidget {
  const SearchMovieScreen({super.key});

  @override
  State<SearchMovieScreen> createState() => _SearchMovieScreenState();
}

class _SearchMovieScreenState extends State<SearchMovieScreen> {
  // Controller để xử lý logic
  final MovieController _controller = MovieController();

  // Controller cho ô tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  // Danh sách kết quả tìm kiếm
  List<MovieModel> _searchResults = [];

  // Trạng thái
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// HÀM TÌM KIẾM PHIM
  Future<void> _searchMovies() async {
    final query = _searchController.text.trim();

    // Kiểm tra input rỗng
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên phim')),
      );
      return;
    }

    // Bắt đầu loading
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      // Gọi controller để tìm kiếm
      // Controller sẽ tự động tìm Firebase trước, sau đó TMDB (kèm trailer)
      final results = await _controller.searchMovies(query);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      // Thông báo nếu tìm được phim từ TMDB
      if (results.isNotEmpty && results.first.id.startsWith('tmdb_')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tìm thấy ${results.length} phim từ TMDB. '
                    'Bạn có thể thêm vào yêu thích!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Tìm kiếm phim',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // --- THANH TÌM KIẾM ---
          _buildSearchBar(),

          // --- KẾT QUẢ TÌM KIẾM ---
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  /// XÂY DỰNG THANH TÌM KIẾM
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E293B),
      child: Row(
        children: [
          // Ô nhập tên phim
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập tên phim...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // Enter để tìm kiếm
              onSubmitted: (_) => _searchMovies(),
            ),
          ),

          const SizedBox(width: 10),

          // Nút tìm kiếm
          ElevatedButton(
            onPressed: _isLoading ? null : _searchMovies,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Tìm',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  /// XÂY DỰNG PHẦN KẾT QUẢ TÌM KIẾM
  Widget _buildSearchResults() {
    // Chưa tìm kiếm lần nào
    if (!_hasSearched) {
      return _buildEmptyState(
        icon: Icons.search,
        message: 'Nhập tên phim và nhấn "Tìm"\nđể bắt đầu tìm kiếm',
        subtitle: 'Tìm kiếm sẽ tự động lấy cả trailer từ TMDB',
      );
    }

    // Đang loading
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang tìm kiếm phim...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    // Không có kết quả
    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.movie_filter_outlined,
        message: 'Không tìm thấy phim nào',
        subtitle: 'Thử tìm với tên khác hoặc tên tiếng Anh',
      );
    }

    // Có kết quả - hiển thị badge nếu là phim TMDB
    final isFromTmdb = _searchResults.first.id.startsWith('tmdb_');

    return Column(
      children: [
        // Badge thông báo nguồn
        if (isFromTmdb)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blueAccent.withOpacity(0.2),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phim từ TMDB - Có trailer đầy đủ! Bấm vào trái tim để thêm yêu thích ❤️',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Grid phim
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final movie = _searchResults[index];

              // Sử dụng MovieItem widget - đã có sẵn chức năng thêm yêu thích
              return MovieItem(movie: movie);
            },
          ),
        ),
      ],
    );
  }

  /// XÂY DỰNG TRẠNG THÁI RỖNG
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

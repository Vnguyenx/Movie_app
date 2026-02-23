import 'package:flutter/material.dart';
import '../../../models/movie_model.dart';
import '../../../controllers/movie_controller.dart';
import '../../../controllers/favorite_controller.dart';

class MovieInfoSection extends StatelessWidget {
  final MovieModel movie;

  // Khởi tạo các controller cần thiết
  final MovieController _movieController = MovieController();
  final FavoriteController _favController = FavoriteController();

  MovieInfoSection({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TIÊU ĐỀ PHIM ---
          Text(
            movie.title,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),

          // --- THÔNG TIN CƠ BẢN (Rating, Năm, Thể loại) ---
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.amber, borderRadius: BorderRadius.circular(4)),
              child: Text(
                "${movie.rating}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(width: 15),
            Text("${movie.year}",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(movie.genre,
                  style: const TextStyle(color: Colors.blueAccent)),
            ),
          ]),

          const SizedBox(height: 25),

          // --- NÚT CHỨC NĂNG (Trailer & Yêu thích) ---
          Row(children: [
            // Nút Xem Trailer
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _movieController.openTrailer(movie.trailerUrl, context),
                icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                label: const Text("Xem Trailer",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(width: 15),

            // Nút Thêm vào yêu thích (StreamBuilder để đổi màu real-time)
            StreamBuilder<bool>(
              stream: _favController.isFavoriteStream(movie.id),
              builder: (context, snapshot) {
                final isLiked = snapshot.data ?? false;
                return IconButton(
                  onPressed: () async {
                    final success = await _favController.toggleFavorite(movie);

                    if (!success) {
                      // Điều hướng sang màn hình đăng nhập
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.redAccent : Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 25),

          // --- NỘI DUNG PHIM ---
          const Text("Nội dung",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            movie.description,
            style: const TextStyle(
                color: Colors.white70, height: 1.6, fontSize: 15),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../routes/app_routes.dart';
import '../controllers/favorite_controller.dart';

class MovieItem extends StatelessWidget {
  final MovieModel movie;
  final double? width;

  MovieItem({
    super.key,
    required this.movie,
    this.width,
  });

  // Controller
  final FavoriteController _favController = FavoriteController();

  // ================================
  // XỬ LÝ KHI BẤM TRÁI TIM
  // ================================
  Future<void> _onHeartTap(BuildContext context, bool isLiked) async {
    final success = await _favController.toggleFavorite(movie);

    // Nếu chưa đăng nhập -> chuyển Login
    if (!success) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    // ----- LOGIC HIỂN THỊ -----
    if (!isLiked) {
      // Vừa thêm
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã thêm '${movie.title}' vào yêu thích!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // ================================
  // BUILD UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Chuyển sang chi tiết phim
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.movieDetail,
          arguments: movie,
        );
      },
      child: Container(
        width: width ?? 130,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================
            // POSTER + ICON HEART
            // ================================
            Expanded(
              child: Stack(
                children: [
                  // Poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      movie.posterUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(color: Colors.grey[900]);
                      },
                    ),
                  ),

                  // Heart
                  Positioned(
                    top: 5,
                    right: 5,
                    child: StreamBuilder<bool>(
                      stream:
                          _favController.isFavoriteStream(movie.id.toString()),
                      builder: (context, snapshot) {
                        final isLiked = snapshot.data ?? false;

                        return GestureDetector(
                          onTap: () => _onHeartTap(context, isLiked),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.redAccent : Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ================================
            // TÊN PHIM
            // ================================
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            // ================================
            // RATING
            // ================================
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 4),
                Text(
                  "${movie.rating}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

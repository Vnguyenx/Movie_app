import 'package:flutter/material.dart';
import '../../../models/movie_model.dart';
import '../../../routes/app_routes.dart';

class HeroBanner extends StatelessWidget {
  final List<MovieModel> movies;

  const HeroBanner({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 250, // Tăng chiều cao để ảnh thoáng và đẹp hơn
      child: PageView.builder(
        // viewportFraction 0.85 giúp user thấy 1 phần của ảnh tiếp theo -> kích thích vuốt
        controller: PageController(viewportFraction: 0.85),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.movieDetail,
                  arguments: movie);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 10), // Khoảng cách giữa các banner
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24), // Bo góc mềm mại hơn
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.6), // Bóng đổ đậm hơn chút tạo độ sâu
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. ẢNH NỀN
                    Image.network(
                      movie.posterUrl,
                      fit: BoxFit.cover, // Zoom ảnh full khung
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[850]);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white24),
                          ),
                        );
                      },
                    ),

                    // 2. GRADIENT ĐEN MỜ (Chỉ ở dưới chân để làm nền cho chữ)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 150, // Chỉ phủ gradient 1 nửa dưới
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black
                                  .withOpacity(0.9), // Đen đậm ở dưới cùng
                              Colors.transparent, // Trong suốt dần lên trên
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. THÔNG TIN PHIM (Đơn giản, tinh tế)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tên phim
                          Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24, // Chữ to hơn
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5, // Giãn chữ nhẹ cho sang
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Thể loại & Năm
                          Row(
                            children: [
                              Text(
                                movie.genre,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (movie.year > 0) ...[
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.white54,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  "${movie.year}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

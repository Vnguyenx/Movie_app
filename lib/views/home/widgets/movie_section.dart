import 'package:flutter/material.dart';
import '../../../models/movie_model.dart';
import '../../../widgets/movie_item.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<MovieModel> movies;

  const MovieSection({super.key, required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    // Nếu danh sách rỗng thì ẩn luôn section này cho gọn
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề (Trending, New...)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 2. Danh sách phim cuộn ngang
        SizedBox(
          height: 220, // Chiều cao cố định cho list ngang
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              // Gọi widget MovieItem đã tách
              return MovieItem(movie: movies[index]);
            },
          ),
        ),
      ],
    );
  }
}

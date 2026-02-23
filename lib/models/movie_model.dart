import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  final String id;
  final String title; // Trong DB là 'movieTitle'
  final String posterUrl; // Trong DB là 'moviePoster'
  final String trailerUrl; // MỚI: Link trailer
  final double rating;
  final String genre; // Trong DB là 'category'
  final String description;
  final int year;
  MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    this.trailerUrl = '', // Mặc định rỗng
    this.rating = 0.0,
    this.genre = '',
    this.description = '',
    this.year = 0,
  });

  // --- 1. toMap: Chuyển Object -> Map (để lưu lên Firestore) ---
  Map<String, dynamic> toMap() {
    return {
      // Key bên trái PHẢI KHỚP với key bên Admin
      'movieTitle': title,
      'moviePoster': posterUrl,
      'trailerUrl': trailerUrl, // Lưu link trailer
      'rating': rating,
      'category': genre, // 🔥 Lưu ý: Admin dùng 'category', User dùng 'genre'
      'description': description,
      'year': year,
    };
  }

  // --- 2. fromMap: Chuyển Firestore Map -> Object (để hiển thị) ---
  factory MovieModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MovieModel(
      id: documentId,

      // Map đúng key từ DB vào biến của Dart
      title: data['movieTitle'] ?? 'No Title',
      posterUrl: data['moviePoster'] ?? '',
      trailerUrl: data['trailerUrl'] ?? '', // Lấy link trailer

      rating:
          (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,

      genre:
          data['category'] ?? 'Unknown', // 🔥 Đọc từ 'category' gán vào 'genre'
      description: data['description'] ?? '',
      year: data['year'] ?? 0,
    );
  }
}

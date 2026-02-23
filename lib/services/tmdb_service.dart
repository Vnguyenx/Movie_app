import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class TmdbService {
  static const String _apiKey = '7299ef774c2cae4899fd13ffeb5f3284';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// TÌM KIẾM PHIM (Vẫn tìm bằng Tiếng Việt để hiển thị Tên/Mô tả tiếng Việt)
  static Future<List<MovieModel>> searchMovies(String query) async {
    try {
      // Giữ nguyên language=vi-VN ở đây để lấy tên phim và mô tả tiếng Việt
      final url = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=$query&language=vi-VN',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];

        List<MovieModel> movies = [];
        final limitedResults = results.take(10).toList();

        for (var movieJson in limitedResults) {
          final tmdbId = movieJson['id'];
          // Lấy trailer (Logic mới: Lấy tiếng Anh/Gốc)
          final trailerUrl = await _getTrailer(tmdbId);

          final movie = _convertTmdbToModel(movieJson, trailerUrl: trailerUrl);
          movies.add(movie);
        }

        return movies;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Lỗi TMDB: $e');
      return [];
    }
  }

  static Future<String> _getTrailer(int tmdbId) async {
    try {
      final videosUrl = Uri.parse(
        '$_baseUrl/movie/$tmdbId/videos?api_key=$_apiKey',
      );

      final videosResponse = await http.get(videosUrl);

      if (videosResponse.statusCode == 200) {
        final videosData = json.decode(videosResponse.body);
        final List videos = videosData['results'] ?? [];

        if (videos.isEmpty) return '';

        // 1. Tìm Trailer trên YouTube
        var trailer = videos.firstWhere(
          (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
          orElse: () => null,
        );

        // 2. Nếu không có Trailer, lấy Teaser
        trailer ??= videos.firstWhere(
          (v) => v['site'] == 'YouTube' && v['type'] == 'Teaser',
          orElse: () => null,
        );

        // 3. Lấy video bất kỳ nếu không tìm thấy loại trên
        trailer ??= videos.firstWhere(
          (v) => v['site'] == 'YouTube',
          orElse: () => null,
        );

        if (trailer != null && trailer['key'] != null) {
          return 'https://www.youtube.com/watch?v=${trailer['key']}';
        }
      }
      return '';
    } catch (e) {
      print('❌ Lỗi lấy trailer: $e');
      return '';
    }
  }

  // --- Các hàm phụ trợ giữ nguyên ---
  static MovieModel _convertTmdbToModel(Map<String, dynamic> tmdbData,
      {String trailerUrl = ''}) {
    final genreIds = tmdbData['genre_ids'] as List? ?? [];
    final genre = _getGenreName(genreIds.isNotEmpty ? genreIds[0] : 0);

    final releaseDate = tmdbData['release_date'] ?? '';
    final year = releaseDate.isNotEmpty
        ? int.tryParse(releaseDate.split('-')[0]) ?? 0
        : 0;

    return MovieModel(
      id: 'tmdb_${tmdbData['id']}',
      title: tmdbData['title'] ?? tmdbData['original_title'] ?? 'No Title',
      posterUrl: tmdbData['poster_path'] != null
          ? '$_imageBaseUrl${tmdbData['poster_path']}'
          : '',
      trailerUrl: trailerUrl,
      rating: (tmdbData['vote_average'] ?? 0).toDouble(),
      genre: genre,
      description: tmdbData['overview'] ?? '',
      year: year,
    );
  }

  static String _getGenreName(int genreId) {
    const genreMap = {
      28: 'Hành động',
      12: 'Phiêu lưu',
      16: 'Hoạt hình',
      35: 'Hài',
      80: 'Tội phạm',
      99: 'Tài liệu',
      18: 'Chính kịch',
      10751: 'Gia đình',
      14: 'Giả tưởng',
      36: 'Lịch sử',
      27: 'Kinh dị',
      10402: 'Âm nhạc',
      9648: 'Bí ẩn',
      10749: 'Lãng mạn',
      878: 'Khoa học viễn tưởng',
      10770: 'Phim truyền hình',
      53: 'Giật gân',
      10752: 'Chiến tranh',
      37: 'Viễn Tây',
    };
    return genreMap[genreId] ?? 'Khác';
  }
}

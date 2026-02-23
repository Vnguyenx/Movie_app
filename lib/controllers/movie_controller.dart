import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';

/// CONTROLLER XỬ LÝ LOGIC LIÊN QUAN ĐẾN MOVIES
/// Bao gồm:
/// - Lấy phim từ Firebase
/// - Tìm kiếm phim (Firebase + TMDB)
/// - Lọc và sắp xếp phim
/// - Mở trailer
class MovieController {
  // Kết nối đến collection 'movies' trong Firestore
  final CollectionReference _movieCollection =
      FirebaseFirestore.instance.collection('movies');

  // ============================================================
  // PHẦN 1: LẤY DỮ LIỆU TỪ FIREBASE
  // ============================================================

  /// 1. LẤY DANH SÁCH TẤT CẢ PHIM TỪ FIREBASE
  /// Sắp xếp theo thời gian tạo (mới nhất lên đầu)
  Future<List<MovieModel>> fetchMovies() async {
    try {
      QuerySnapshot snapshot =
          await _movieCollection.orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String id = doc.id;
        return MovieModel.fromMap(data, id);
      }).toList();
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách phim từ Firebase: $e");
      return [];
    }
  }

  /// 2. LẤY CHI TIẾT 1 PHIM THEO ID (CHỈ TỪ FIREBASE)
  Future<MovieModel?> getMovieById(String movieId) async {
    try {
      print('📂 Lấy phim từ Firebase với ID: $movieId');
      final doc = await _movieCollection.doc(movieId).get();

      if (doc.exists) {
        print('✅ Tìm thấy phim trong Firebase');
        return MovieModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }

      print('⚠️ Không tìm thấy phim với ID: $movieId');
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy chi tiết phim: $e');
      return null;
    }
  }

  // ============================================================
  // PHẦN 2: TÌM KIẾM PHIM (FIREBASE + TMDB)
  // ============================================================

  /// 3. TÌM KIẾM PHIM THÔNG MINH
  /// Quy trình:
  /// - Bước 1: Tìm trong Firebase trước (nhanh)
  /// - Bước 2: Nếu không có, tìm trên TMDB (có trailer)
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      print('🔍 Bắt đầu tìm kiếm: "$query"');

      // BƯỚC 1: TÌM TRONG FIREBASE
      final firebaseResults = await _searchInFirebase(query);

      if (firebaseResults.isNotEmpty) {
        print('✅ Tìm thấy ${firebaseResults.length} phim trong Firebase');
        return firebaseResults;
      }

      // BƯỚC 2: TÌM TRÊN TMDB (kèm trailer)
      print('🌐 Không tìm thấy trong Firebase, tìm trên TMDB...');

      final tmdbResults = await TmdbService.searchMovies(query);

      if (tmdbResults.isNotEmpty) {
        print('✅ Tìm thấy ${tmdbResults.length} phim từ TMDB (có trailer)');
      } else {
        print('⚠️ Không tìm thấy phim nào phù hợp');
      }

      return tmdbResults;
    } catch (e) {
      print('❌ Lỗi khi tìm kiếm phim: $e');
      return [];
    }
  }

  /// 4. TÌM KIẾM TRONG FIREBASE (Private method)
  /// Firebase không hỗ trợ tìm kiếm full-text
  Future<List<MovieModel>> _searchInFirebase(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final snapshot = await _movieCollection.get();

      final results = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['movieTitle'] ?? '').toString().toLowerCase();
        return title.contains(lowerQuery);
      }).map((doc) {
        return MovieModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      return results;
    } catch (e) {
      print('❌ Lỗi khi tìm trong Firebase: $e');
      return [];
    }
  }

  // ============================================================
  // PHẦN 3: LỌC VÀ SẮP XẾP PHIM
  // ============================================================

  /// 5. LỌC PHIM THEO NHIỀU ĐIỀU KIỆN
  List<MovieModel> applyFilters({
    required List<MovieModel> sourceList,
    String query = '',
    String? category,
    int? year,
  }) {
    return sourceList.where((movie) {
      // Điều kiện 1: Tên phim
      final bool matchName =
          movie.title.toLowerCase().contains(query.toLowerCase());

      // Điều kiện 2: Thể loại
      final bool matchCategory =
          (category == null || category == 'Tất cả' || movie.genre == category);

      // Điều kiện 3: Năm
      final bool matchYear = (year == null || movie.year == year);

      return matchName && matchCategory && matchYear;
    }).toList();
  }

  /// 6. LẤY DANH SÁCH CÁC THỂ LOẠI CÓ SẴN
  List<String> getAvailableCategories(List<MovieModel> movies) {
    final categories = movies.map((e) => e.genre).toSet().toList();
    categories.removeWhere((element) => element.isEmpty);
    categories.sort();
    return ['Tất cả', ...categories];
  }

  /// 7. LẤY DANH SÁCH CÁC NĂM CÓ SẴN
  List<int> getAvailableYears(List<MovieModel> movies) {
    final years = movies.map((e) => e.year).toSet().toList();
    years.removeWhere((element) => element == 0);
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  // ============================================================
  // PHẦN 4: MỞ TRAILER
  // ============================================================

  /// 8. MỞ TRAILER TRÊN YOUTUBE HOẶC BROWSER
  Future<void> openTrailer(String? url, BuildContext context) async {
    // BƯỚC 1: Kiểm tra url có hợp lệ không
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phim này chưa có link trailer!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // BƯỚC 2: Parse URL
    final uri = Uri.parse(url);

    try {
      // BƯỚC 3: Mở URL
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ Đã mở trailer: $url');
      } else {
        await launchUrl(uri);
        print('⚠️ Mở trailer bằng phương thức fallback');
      }
    } catch (e) {
      print('❌ Lỗi khi mở trailer: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không thể mở đường dẫn: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

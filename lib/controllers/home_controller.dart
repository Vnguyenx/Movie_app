import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class HomeController {
  // Lấy toàn bộ danh sách phim từ collection 'movies'
  Stream<List<MovieModel>> getMoviesStream() {
    return FirebaseFirestore.instance
        .collection('movies')
        .orderBy('createdAt', descending: true) // Phim mới nhất lên đầu
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MovieModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}

import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../controllers/interaction_controller.dart'; // Import controller
import 'widgets/movie_info_section.dart';
import 'widgets/review_section.dart';
import 'widgets/review_input.dart'; // Import widget nhập liệu

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final InteractionController _interactionController = InteractionController();
  bool _isSending = false;

  // --- LOGIC GỬI COMMENT (Chuyển từ Section ra đây) ---
  Future<void> _onSendComment(String content, double rating) async {
    if (content.isEmpty && rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa nhập nội dung hoặc chọn sao!")),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await _interactionController.addInteraction(
        movieId: widget.movie.id,
        content: content,
        rating: rating,
        type: 'comment',
      );
      // Ẩn bàn phím sau khi gửi
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      // resizeToAvoidBottomInset: true giúp đẩy thanh nhập liệu lên khi bật bàn phím
      resizeToAvoidBottomInset: true,

      body: Column(
        children: [
          // 1. PHẦN NỘI DUNG CUỘN ĐƯỢC (Chiếm hết không gian còn lại)
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Header Ảnh Parallax
                SliverAppBar(
                  expandedHeight: 450,
                  backgroundColor: const Color(0xFF0F172A),
                  pinned: true,
                  leading: IconButton(
                    icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.black26, shape: BoxShape.circle),
                        child: Icon(Icons.arrow_back, color: Colors.white)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.movie.posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[850]),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF0F172A).withOpacity(0.5),
                                const Color(0xFF0F172A),
                              ],
                              stops: const [0.6, 0.85, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Widget 1: Thông tin phim
                SliverToBoxAdapter(
                  child: MovieInfoSection(movie: widget.movie),
                ),

                // Widget 2: Danh sách bình luận (Chỉ hiển thị list)
                SliverToBoxAdapter(
                  child: ReviewSection(movieId: widget.movie.id),
                ),
              ],
            ),
          ),

          // 2. THANH NHẬP LIỆU CỐ ĐỊNH Ở ĐÁY (Bottom Bar)
          // Đặt ngoài Expanded để nó luôn nằm dưới cùng
          ReviewInput(
            onSend: _onSendComment,
            isSending: _isSending,
          ),
        ],
      ),
    );
  }
}

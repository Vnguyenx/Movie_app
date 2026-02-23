import 'package:flutter/material.dart';
import '../../../controllers/interaction_controller.dart';
import '../../../models/interaction_model.dart';
import 'review_item.dart';

class ReviewSection extends StatelessWidget {
  final String movieId;

  // Instance controller để lấy stream
  final InteractionController _interactionController = InteractionController();

  ReviewSection({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("Bình luận & Đánh giá",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),

        // --- DANH SÁCH BÌNH LUẬN ---
        StreamBuilder<List<InteractionModel>>(
          stream: _interactionController.getInteractionsStream(movieId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final interactions = snapshot.data ?? [];

            if (interactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: Text("Chưa có đánh giá nào. Hãy là người đầu tiên!",
                      style: TextStyle(
                          color: Colors.white54, fontStyle: FontStyle.italic)),
                ),
              );
            }

            // ListView nằm trong CustomScrollView của màn hình cha
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Không cuộn riêng
              itemCount: interactions.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                return ReviewItem(item: interactions[index]);
              },
            );
          },
        ),

        // Thêm khoảng trắng ở dưới để nội dung không bị che bởi thanh nhập liệu
        const SizedBox(height: 100),
      ],
    );
  }
}

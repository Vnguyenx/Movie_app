import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/interaction_model.dart';
import '../../../widgets/user_name_fetcher.dart'; // Import widget vừa tạo ở trên

class ReviewItem extends StatelessWidget {
  final InteractionModel item;

  const ReviewItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(item.createdAt);
    // Tính số sao hiển thị (DB lưu 10, hiển thị 5)
    double starCount = item.ratingValue / 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person_outline, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔥 Dùng Widget lấy tên thật thay vì text cứng
                    Expanded(
                      child: UserNameFetcher(
                        userId: item.userId,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),

                    // Badge điểm số (màu vàng)
                    if (item.ratingValue > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          children: [
                            Text("${item.ratingValue.toInt()}",
                                style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            const Icon(Icons.star,
                                color: Colors.amber, size: 12),
                          ],
                        ),
                      ),
                  ],
                ),

                // Hàng sao nhỏ
                if (item.ratingValue > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < starCount ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                    ),
                  ),

                Text(formattedDate,
                    style:
                        const TextStyle(color: Colors.white30, fontSize: 11)),
                const SizedBox(height: 4),

                if (item.content.isNotEmpty)
                  Text(
                    item.content,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

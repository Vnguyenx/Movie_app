import 'package:flutter/material.dart';

class ReviewInput extends StatefulWidget {
  final Function(String content, double rating) onSend;
  final bool isSending;

  const ReviewInput({super.key, required this.onSend, this.isSending = false});

  @override
  State<ReviewInput> createState() => _ReviewInputState();
}

class _ReviewInputState extends State<ReviewInput> {
  final TextEditingController _controller = TextEditingController();
  double _uiStarRating = 0;

  void _handleSend() {
    // Quy đổi sao UI (5) -> DB (10)
    double finalRating = _uiStarRating * 2;
    widget.onSend(_controller.text, finalRating);

    // Reset sau khi gửi
    _controller.clear();
    setState(() {
      _uiStarRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng chọn sao
          Row(
            children: [
              const Text("Đánh giá:", style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 10),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _uiStarRating = index + 1.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        index < _uiStarRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 10),
              if (_uiStarRating > 0)
                Text("${(_uiStarRating * 2).toInt()}/10",
                    style: const TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 12),

          // Ô nhập liệu
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Viết cảm nghĩ...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: widget.isSending ? null : _handleSend,
                icon: widget.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.blueAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

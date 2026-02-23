import 'package:flutter/material.dart';
import '../../controllers/user_chat_controller.dart';
import '../../models/chat_model.dart';
import '../../widgets/chat_bubble.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final UserChatController _controller = UserChatController();
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Khi mở màn hình -> Đánh dấu đã đọc hết tin nhắn
    _controller.markAsRead();
  }

  void _onSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _controller.sendMessage(text);
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold này sẽ đè lên MainLayout
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Hỗ trợ khách hàng",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          // Nút Back
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Quay về MainLayout
        ),
      ),
      body: Column(
        children: [
          // 1. Danh sách tin nhắn
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _controller.getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.forum_outlined,
                            size: 60, color: Colors.white24),
                        const SizedBox(height: 10),
                        const Text("Bắt đầu trò chuyện với Admin",
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Tin nhắn mới nhất ở dưới cùng
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    // Logic: isMe (User) là khi isAdmin == false
                    return ChatBubble(
                      text: msg.text,
                      isMe: !msg.isAdmin,
                    );
                  },
                );
              },
            ),
          ),

          // 2. Thanh nhập liệu (Input Bar)
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _onSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

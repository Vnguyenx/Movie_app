import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool
      isAdmin; // True: Tin nhắn của Admin (nằm bên phải), False: User (bên trái)
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isAdmin,
    required this.createdAt,
  });

  factory ChatMessage.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

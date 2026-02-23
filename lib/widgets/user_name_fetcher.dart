import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserNameFetcher extends StatelessWidget {
  final String userId;
  final TextStyle? style;

  const UserNameFetcher({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context) {
    // Nếu không có userId (khách), hiện luôn
    if (userId.isEmpty || userId == 'anonymous') {
      return Text("Khách", style: style);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("...", style: style);
        }

        // Lấy tên từ field 'displayName' hoặc 'name' trong collection users

        String name = "Người dùng";
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['displayName'] ?? "Người dùng";
        }

        return Text(name, style: style, overflow: TextOverflow.ellipsis);
      },
    );
  }
}

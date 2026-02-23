import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = ProfileController();

  // --- CONTROLLER CHO CÁC TRƯỜNG SỬA ĐƯỢC ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  // --- BIẾN CHO CÁC TRƯỜNG READ-ONLY (CHỈ ĐỌC) ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _createdAtIndexController =
      TextEditingController();
  final TextEditingController _updatedAtController = TextEditingController();

  bool _isLoading = false;
  bool _isBanned = false;
  DateTime? _bannedUntil;

  // Lấy ID user hiện tại để dùng khi Update
  User? get authUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _avatarUrlController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _createdAtIndexController.dispose();
    _updatedAtController.dispose();
    super.dispose();
  }

  // --- HÀM 1: LẤY DỮ LIỆU ---
  Future<void> _loadData() async {
    // 1. Điền tạm dữ liệu từ Auth (để không bị trống trơn lúc chờ)
    _emailController.text = authUser?.email ?? "";
    _nameController.text = authUser?.displayName ?? "";
    _avatarUrlController.text = authUser?.photoURL ?? "";

    // 2. Gọi Controller lấy dữ liệu chi tiết từ Firestore
    UserModel? userModel = await _controller.getCurrentUser();

    if (userModel != null) {
      setState(() {
        // A. Điền dữ liệu sửa được
        _nameController.text = userModel.displayName;
        _phoneController.text = userModel.phone;
        if (userModel.photoURL.isNotEmpty) {
          _avatarUrlController.text = userModel.photoURL;
        }

        // B. Điền dữ liệu Read-Only (Hệ thống)
        _roleController.text =
            userModel.role.toUpperCase(); // Viết hoa cho đẹp (ADMIN)
        _createdAtIndexController.text = _formatDate(userModel.createdAt);
        _updatedAtController.text = userModel.updatedAt != null
            ? _formatDate(userModel.updatedAt!)
            : "Chưa chỉnh sửa lần nào";

        // C. Check Ban
        _isBanned = userModel.isBanned;
        _bannedUntil = userModel.bannedUntil;
      });
    }
  }

  // --- HÀM 2: LƯU DỮ LIỆU ---
  Future<void> _handleUpdate() async {
    if (authUser == null) return;

    FocusScope.of(context).unfocus(); // Ẩn bàn phím
    setState(() => _isLoading = true);

    // Gọi Controller update
    String? error = await _controller.updateUserProfile(
      uid: authUser!.uid,
      displayName: _nameController.text.trim(),
      photoURL: _avatarUrlController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Cập nhật thành công!"),
            backgroundColor: Colors.green),
      );
      // 🔥 Quan trọng: Load lại data để thấy ngày 'updatedAt' mới nhất
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  // --- HÀM 3: LOGOUT ---
  Future<void> _handleSignOut() async {
    await _controller.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false);
    }
  }

  // Hàm phụ trợ format ngày tháng đơn giản
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} lúc ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    // Logic hiển thị ảnh preview
    String previewImage = _avatarUrlController.text.trim();
    if (previewImage.isEmpty) {
      previewImage = authUser?.photoURL ??
          "https://ui-avatars.com/api/?name=${authUser?.email}&background=random";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. AVATAR ---
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(previewImage),
                    onError: (_, __) {},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. BANNER CẢNH BÁO BAN (Nếu có) ---
            if (_isBanned)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Tài khoản bị khóa đến: ${_formatDate(_bannedUntil!)}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),

            // --- 3. NHÓM THÔNG TIN SỬA ĐƯỢC ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("THÔNG TIN CƠ BẢN",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            const SizedBox(height: 10),

            _buildTextField(
                label: "Tên hiển thị",
                controller: _nameController,
                icon: Icons.person),
            const SizedBox(height: 15),
            _buildTextField(
                label: "Số điện thoại",
                controller: _phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            _buildTextField(
                label: "Link Avatar",
                controller: _avatarUrlController,
                icon: Icons.image,
                onChanged: (val) =>
                    setState(() {}) // Cập nhật ảnh preview ngay khi gõ
                ),

            const SizedBox(height: 25),

            // --- 4. NHÓM THÔNG TIN HỆ THỐNG (READ ONLY) ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("THÔNG TIN HỆ THỐNG",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            const SizedBox(height: 10),

            _buildTextField(
                label: "Email",
                controller: _emailController,
                icon: Icons.email,
                isReadOnly: true),
            const SizedBox(height: 15),

            // Role & Ban Status nằm cùng 1 hàng cho gọn
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        label: "Vai trò",
                        controller: _roleController,
                        icon: Icons.security,
                        isReadOnly: true)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField(
                        label: "Trạng thái",
                        controller: TextEditingController(
                            text: _isBanned ? "ĐANG BỊ KHÓA" : "Hoạt động"),
                        icon: _isBanned ? Icons.lock : Icons.check_circle,
                        isReadOnly: true,
                        textColor:
                            _isBanned ? Colors.redAccent : Colors.greenAccent)),
              ],
            ),

            const SizedBox(height: 15),
            _buildTextField(
                label: "Ngày tạo tài khoản",
                controller: _createdAtIndexController,
                icon: Icons.calendar_today,
                isReadOnly: true),
            const SizedBox(height: 15),
            _buildTextField(
                label: "Cập nhật lần cuối",
                controller: _updatedAtController,
                icon: Icons.history,
                isReadOnly: true),

            const SizedBox(height: 40),

            // --- 5. BUTTONS ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Lưu thay đổi",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text("Đăng xuất",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: GIÚP CODE GỌN GÀNG ---
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isReadOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    Color? textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: isReadOnly, // Chặn sửa nếu là ReadOnly
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: isReadOnly ? FontWeight.bold : FontWeight.normal),
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, color: isReadOnly ? Colors.white30 : Colors.white70),
            filled: true,
            // Nếu ReadOnly thì màu nền tối hơn để phân biệt
            fillColor: isReadOnly ? Colors.black26 : const Color(0xFF1E293B),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }
}

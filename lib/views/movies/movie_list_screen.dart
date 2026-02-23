import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../widgets/movie_item.dart';
import '../../controllers/movie_controller.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // Tái sử dụng Controller để dùng các hàm tiện ích (lấy năm, lọc...)
  final MovieController _movieController = MovieController();
  final TextEditingController _searchController = TextEditingController();

  // --- STATE ---
  String _searchText = "";
  String _selectedGenre = "Tất cả";
  int? _selectedYear; // Mặc định là null (Tất cả năm)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Khám Phá Kho Phim",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. THANH TÌM KIẾM ---
          _buildSearchBar(),

          // --- 2. DATA & FILTERS ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('movies').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Lỗi tải dữ liệu",
                          style: TextStyle(color: Colors.white)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // A. Parse dữ liệu
                final allMovies = snapshot.data!.docs.map((doc) {
                  return MovieModel.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                // B. Lấy danh sách FILTER động từ data (Dùng logic của Controller)
                // Lưu ý: Controller dùng 'category', Model User dùng 'genre' -> ta map nhẹ lại
                final availableGenres = _movieController.getAvailableCategories(
                    allMovies); // Tự động lấy list genre
                final availableYears = _movieController
                    .getAvailableYears(allMovies); // Tự động lấy list year

                // C. Áp dụng bộ lọc (Logic lọc 3 lớp: Tên + Genre + Năm)
                final displayedMovies = allMovies.where((movie) {
                  // 1. Tên
                  bool matchName =
                      movie.title.toLowerCase().contains(_searchText);
                  // 2. Thể loại (Genre)
                  bool matchGenre = _selectedGenre == "Tất cả" ||
                      movie.genre == _selectedGenre;
                  // 3. Năm (Year) - Logic mới thêm vào
                  bool matchYear =
                      _selectedYear == null || movie.year == _selectedYear;

                  return matchName && matchGenre && matchYear;
                }).toList();

                return Column(
                  children: [
                    // --- THANH CÔNG CỤ LỌC (NĂM + THỂ LOẠI) ---
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          // Nút chọn Năm (Dropdown gọn nhẹ)
                          _buildYearDropdown(availableYears),

                          const SizedBox(width: 10),
                          // Đường kẻ dọc ngăn cách
                          Container(
                              width: 1, height: 20, color: Colors.white24),
                          const SizedBox(width: 10),

                          // Danh sách Thể loại (Scroll ngang)
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: availableGenres.length,
                              itemBuilder: (context, index) {
                                final genre = availableGenres[index];
                                return _buildGenreChip(genre);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- GRID VIEW HIỂN THỊ PHIM ---
                    Expanded(
                      child: displayedMovies.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                              ),
                              itemCount: displayedMovies.length,
                              itemBuilder: (context, index) {
                                return MovieItem(
                                  movie: displayedMovies[index],
                                  width: double.infinity,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Dropdown chọn Năm ---
  Widget _buildYearDropdown(List<int> years) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedYear,
          dropdownColor: const Color(0xFF1E293B), // Màu nền menu xổ xuống
          icon:
              const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
          hint: const Text("Năm",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: [
            // Item mặc định: Tất cả
            const DropdownMenuItem<int?>(
              value: null,
              child: Text("Tất cả năm"),
            ),
            // Các năm có trong dữ liệu
            ...years.map((year) => DropdownMenuItem<int?>(
                  value: year,
                  child: Text(year.toString()),
                )),
          ],
          onChanged: (val) {
            setState(() {
              _selectedYear = val;
            });
          },
        ),
      ),
    );
  }

  // --- Widget: Chip chọn Thể loại ---
  Widget _buildGenreChip(String genre) {
    final isSelected = genre == _selectedGenre;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(genre),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedGenre = genre;
          });
        },
        backgroundColor: Colors.transparent,
        selectedColor: Colors.blueAccent,
        labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: isSelected ? Colors.blueAccent : Colors.white10)),
      ),
    );
  }

  // --- Widget: Thanh tìm kiếm ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value.toLowerCase();
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Tìm tên phim...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchText = "";
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // --- Widget: Màn hình trống ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_filter, size: 60, color: Colors.white24),
          const SizedBox(height: 10),
          Text(
            "Không tìm thấy phim phù hợp",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

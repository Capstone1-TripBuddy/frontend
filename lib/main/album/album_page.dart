import 'package:flutter/material.dart';
import '../photo/fetch_photos.dart';


class AlbumPage extends StatefulWidget {
  final String albumName;
  const AlbumPage({super.key, required this.albumName});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<String> _imageUrls = []; // 서버에서 받은 이미지 URL 리스트
  bool _isLoading = true; // 로딩 상태 관리
  bool _isError = false; // 에러 상태 관리

  @override
  void initState() {
    super.initState();
    _loadImages(); // 페이지가 열릴 때 서버에서 이미지 가져오기
  }

  Future<void> _loadImages() async {
    try {
      final images = await fetchImages(widget.albumName); // fetchImages 호출
      setState(() {
        _imageUrls = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
      debugPrint('이미지 가져오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albumName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : _isError
          ? const Center(
        child: Text('이미지를 불러오는 중 오류가 발생했습니다.'),
      ) // 에러 발생 시 메시지
          : _imageUrls.isEmpty
          ? const Center(
        child: Text('선택한 카테고리에 이미지가 없습니다.'),
      ) // 이미지 없음 표시
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 한 줄에 3개의 이미지
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1, // 정사각형 비율
          ),
          itemCount: _imageUrls.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _imageUrls[index], // 서버에서 받은 이미지 URL
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(), // 로딩 중
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red), // 오류 시 아이콘 표시
              ),
            );
          },
        ),
      ),
    );
  }
}
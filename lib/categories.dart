import 'package:flutter/material.dart';
import 'category_detail_page.dart';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  /* 서버에서 가져온 데이터를 저장할 변수
  Map<String, List<String>> categorizedImages = {};
  @override
  void initState() {
    super.initState();
    fetchCategoryData(); // 페이지 초기화 시 데이터 가져오기
  }
  Future<void> fetchCategoryData() async {
    final response = await http.get(Uri.parse('서버주소/api/albums/{group-id}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        categorizedImages = Map<String, List<String>>.from(data);
      });
    } else {
      print('Failed to load data');
    }
  }

  Future<void> downloadImages(String category) async {
    final response = await http.post(
      Uri.parse('서버주소/api/albums/download'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category': category}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$category 카테고리의 모든 사진을 다운로드했습니다.'),
      ));
    } else {
      print('Failed to download images for $category');
    }
  }
  */

  // 예시 데이터: 실제 데이터는 서버에서 받아와야 합니다.
  final Map<String, List<String>> categorizedImages = {
    '풍경': ['https://picsum.photos/200/300', 'https://picsum.photos/200/300'],
    '인물': ['https://picsum.photos/200/300', 'https://picsum.photos/200/300'],
    '동물': ['https://example.com/animal1.jpg', 'https://example.com/animal2.jpg'],
    '음식': ['https://example.com/food1.jpg', 'https://example.com/food2.jpg'],
  };

  Future<void> downloadImages(String category, List<String> imageUrls) async {
    for (var url in imageUrls) {
      try {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          // 이미지 데이터를 로컬에 저장하는 로직이 필요합니다.
          // 예시로는 디렉토리 생성 및 파일 쓰기를 포함할 수 있습니다.
          print('Downloaded image from $url');
        } else {
          print('Failed to download image: $url');
        }
      } catch (e) {
        print('Error downloading image: $e');
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$category 카테고리의 모든 사진을 다운로드했습니다.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: categorizedImages.entries.map((entry) {
            return GestureDetector(
              onTap: () {
                // 클릭 시 해당 카테고리 이미지 페이지로 이동하거나 다른 작업 수행 가능
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailPage(
                      categoryName: entry.key,
                      imageUrls: entry.value,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: double.infinity,
                  height: 200, // 카드 크기 조정
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(entry.value[0]), // 첫 이미지를 카드 배경으로 사용
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          children: [
                            Icon(Icons.folder, color: Colors.grey[600], size: 30),
                            const SizedBox(width: 5),
                            Text(
                              entry.key,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'download') {
                              downloadImages(entry.key, entry.value);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'download',
                              child: Row(
                                children: [
                                  Icon(Icons.download, color: Colors.black54),
                                  SizedBox(width: 8),
                                  Text('전체 다운로드'),
                                ],
                              ),
                            ),
                          ],
                          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
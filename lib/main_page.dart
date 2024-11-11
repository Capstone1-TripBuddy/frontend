import 'package:flutter/material.dart';
import 'image_upload_page.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 예시 데이터: 실제 데이터는 서버에서 받아와야 합니다.
  final Map<String, List<String>> categorizedImages = {
    '풍경': ['https://picsum.photos', 'https://picsum.photos/200/400'],
    '인물': ['https://example.com/portrait1.jpg', 'https://example.com/portrait2.jpg'],
    '동물': ['https://example.com/animal1.jpg', 'https://example.com/animal2.jpg'],
    '음식': ['https://example.com/food1.jpg', 'https://example.com/food2.jpg'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 분류'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImageUploadPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: categorizedImages.entries.map((entry) {
            return GestureDetector(
              onTap: () {
                // 클릭 시 해당 카테고리 이미지 페이지로 이동하거나 다른 작업 수행 가능
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
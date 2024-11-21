import 'package:flutter/material.dart';
import 'category/categories.dart';
import 'photo/photo_upload_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                // 사이드바 열기 로직
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // 알림 기능 로직
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // 사진 업로드 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhotoUploadPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 사용자 프로필 헤더
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              accountName: const Text(
                'John Doe',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                '@johndoe',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/avatar.jpg'), // 프로필 이미지
              ),
            ),
            // Profile 메뉴
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('프로필'),
              onTap: () {
                // 프로필 페이지로 이동
              },
            ),
            // Group Management 메뉴
            ListTile(
              leading: const Icon(Icons.group, color: Colors.black),
              title: const Text('그룹 리스트'),
              onTap: () {
                // 그룹 관리 페이지로 이동
              },
            ),
            const Divider(),
            // Logout 메뉴
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                // 로그아웃 로직
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCategoryCard(
                    context,
                    '풍경',
                    'assets/images/background.jpg',
                  ),
                  _buildCategoryCard(
                    context,
                    '사람',
                    'assets/images/background.jpg',
                  ),
                  _buildCategoryCard(
                    context,
                    '음식',
                    'assets/images/background.jpg',
                  ),
                  _buildCategoryCard(
                    context,
                    '동물',
                    'assets/images/background.jpg',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                '사진 피드',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPhotoFeedItem(
                context,
                'Jane Smith',
                'Bali, Indonesia',
                'Amazing sunset at the beach! 🌅',
                'assets/images/background.jpg',
                234,
                2,
              ),
              _buildPhotoFeedItem(
                context,
                'John Doe',
                'Paris, France',
                'Beautiful shot!',
                'assets/images/background.jpg',
                189,
                4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        // 해당 카테고리 상세 페이지로 이동
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoFeedItem(BuildContext context, String name, String location,
      String description, String imagePath, int likes, int comments) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
            title: Text(name),
            subtitle: Text(location),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$likes'),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$comments'),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$name ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: description),
                    ],
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_buddy/welcome/user_provider.dart';

import '../group/group_provider.dart';
import 'album/fetch_album.dart';
import 'photo/photo_upload_page.dart';
import 'photo_feed_page.dart';

class DashboardPage extends StatefulWidget {
  final int groupId;
  final int userId;
  const DashboardPage({super.key, required this.groupId, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      final albums = await fetchAlbumsByGroupId(widget.groupId);
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading albums: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final groupData = groupProvider.groupData;
    final groupName = (groupData != null && groupData['id'] == widget.groupId)? groupData['groupName'] ?? 'Unknown Group' : 'Loading...';
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.userData?['name'] ?? 'Guest'; // 기본값 설정
    final userEmail = userProvider.userData?['email'] ?? 'guest@example.com';
    final userProfile = userProvider.userData?['profilePicture'];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          groupName,
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                /// 사이드바 열기 로직
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
              Navigator.pushReplacementNamed(context, '/notification');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // 사진 업로드 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhotoUploadPage(groupId: widget.groupId, userId: widget.userId,)),
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
              accountName: Text(
                userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: userProfile != null
                    ? NetworkImage(userProfile)
                    : const AssetImage('assets/images/profilebase.PNG') as ImageProvider,
                backgroundColor: Colors.grey[300], // 프로필 이미지
              ),
            ),
            // Profile 메뉴
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('프로필'),
              onTap: () {
                // 프로필 페이지로 이동
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            // Group Management 메뉴
            ListTile(
              leading: const Icon(Icons.group, color: Colors.black),
              title: const Text('그룹 리스트'),
              onTap: () {
                // 그룹 관리 페이지로 이동
                Navigator.pushReplacementNamed(context, '/group_list');
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
                userProvider.clearUserData();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃되었습니다.')),
                );
              },
            ),
          ],
        ),
      ),
      body:  _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '태그',
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // 태그 버튼
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // 가로로 스크롤 가능
                    child: Row(
                      children: [
                        _buildCategoryButton('Landscape', Icons.landscape),
                        const SizedBox(width: 6), // 버튼 간 간격
                        _buildCategoryButton('Food', Icons.restaurant),
                        const SizedBox(width: 6),
                        _buildCategoryButton('Animals', Icons.pets),
                        const SizedBox(width: 6),
                        _buildCategoryButton('People', Icons.person),
                        const SizedBox(width: 6),
                        _buildCategoryButton('Others', Icons.category),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey, // 선 색상
                    thickness: 1.0,     // 선 두께
                  ),
                  // 날짜 구분
                  const Text(
                    'June 15, 2023',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 버튼 클릭 시 동작 추가
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PhotoFeedPage()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.note_alt, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  Widget _buildCategoryButton(String label, dynamic iconOrImage) {
    return ElevatedButton.icon(
      onPressed: () {
        // 카테고리 클릭 로직
      },
      icon: iconOrImage is IconData
          ? Icon(iconOrImage, size: 16) // 아이콘인 경우
          : ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          iconOrImage,
          width: 16,
          height: 16,
          fit: BoxFit.cover,
        ), // 이미지 URL인 경우
      ),
      label: Text(label, style: const TextStyle(fontSize: 12),),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }

}
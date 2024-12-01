import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_buddy/main/leave_memory_page.dart';

import '../welcome/user_provider.dart';
import '../group/group_provider.dart';

import 'notification_page.dart';
import 'profile_page.dart';
import 'photo_upload_page.dart';
import 'photo_feed_page.dart';
import 'fetch_main.dart';

class DashboardPage extends StatefulWidget {
  final int groupId;
  final int userId;
  const DashboardPage({super.key, required this.groupId, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> _photos = [];
  List<Map<String, dynamic>> _members = [];
  final List<Map<String, dynamic>> _tags = [
    {'label': '풍경', 'icon': Icons.landscape},
    {'label': '음식', 'icon': Icons.restaurant},
    {'label': '동물', 'icon': Icons.pets},
    {'label': '기타', 'icon': Icons.category},
  ];

  int? _selectedMember; // 선택된 멤버 ID
  String? _selectedTag; // 선택된 태그

  int _currentPage = 0; //scroll
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMembers = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _loadMembers();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 300 && !_isLoadingMore && _currentPage + 1 < _totalPages) {
        _loadMorePhotos();
      }
    });
  }

  Future<void> _loadPhotos([String? tagFilter, int page = 0]) async {
    setState(() => _isLoading = true);

    try {
      final photos = await fetchPhotosByGroupId(widget.groupId, tagFilter: tagFilter, page: page);
      setState(() {
        _photos = photos['content'];
        _totalPages = photos['totalPages'];
        _currentPage = page;
      });
    } catch (e) {
      //print('Error loading photos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePhotos() async {
    if (_currentPage + 1 >= _totalPages) return;

    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final photos = await fetchPhotosByGroupId(widget.groupId, tagFilter: _selectedTag, page: nextPage);
      setState(() {
        _photos.addAll(photos['content']);
        _currentPage = nextPage;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more photos: $e')),
      );
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _loadMembers() async {
    try {
      // 서버와 통신하여 멤버 정보를 가져옵니다.
      final members = await fetchGroupMembers(widget.groupId); // 서버 요청 함수
      setState(() {
        _members = members;
        _isLoadingMembers = false;

      });
    } catch (e) {
      setState(() {
        _isLoadingMembers = false;
      });
      //print('Error loading group members: $e');
    }
  }

  void _downloadAndUnzipAlbum() async {
    final String albumName = _selectedTag ?? _selectedMember.toString();
    try {
      await downloadAlbumAndExtract(
        groupId: widget.groupId,
        albumName: albumName,
      );
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앨범 다운로드 및 압축 해제 완료')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다운로드 중 오류 발생: $e')),
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
    final groupedPhotos = _groupPhotosByDate();
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
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: _downloadAndUnzipAlbum,
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // 알림 기능 로직
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage(groupId: widget.groupId, userId: widget.userId,)),
              );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
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
                groupProvider.clearGroupData();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃되었습니다.')),
                );
              },
            ),
          ],
        ),
      ),
      body:  _isLoading || _isLoadingMembers
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
          ? const Center(
              child: Text(
                '사진이 없습니다.\n사진을 업로드 해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
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
                        // 멤버 버튼
                        ..._buildMemberButtons(),
                        // 태그 버튼
                        ..._buildTagButtons(),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey, // 선 색상
                    thickness: 1.0,     // 선 두께
                  ),
                  const SizedBox(height: 6),
                  // 날짜 구분
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: groupedPhotos.keys.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, dateIndex) {
                            if (dateIndex == groupedPhotos.keys.length) {
                              // 로딩 인디케이터 추가
                              return const Center(child: CircularProgressIndicator());
                            }
                            final date = groupedPhotos.keys.elementAt(dateIndex);
                            final photos = groupedPhotos[date]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  child: Text(
                                    date,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 4,
                                    mainAxisSpacing: 4,
                                  ),
                                  itemCount: photos.length,
                                  itemBuilder: (context, index) {
                                    final photo = photos[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // 사진 클릭 로직
                                        _showPhotoDialog(context, photos, index);
                                      },
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            '${photo['fileUrl']}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            },
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == 'memory') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LeaveMemoryPage(
                                                        photo: {
                                                          'photoId': photo['photoId'], // photoId 전달
                                                          'fileUrl': photo['fileUrl'], // fileUrl 전달
                                                        },
                                                        groupId: widget.groupId, // 전달할 groupId
                                                        userId: widget.userId,  // 전달할 userId
                                                      ),
                                                    ),
                                                  );// 메모 남기기 로직
                                                }
                                              },
                                              icon: const Icon(Icons.more_vert, color: Colors.white),
                                              itemBuilder: (BuildContext context) => [
                                                const PopupMenuItem(
                                                  value: 'memory',
                                                  child: ListTile(
                                                    leading: Icon(Icons.comment),
                                                    title: Text('Leave a Memory'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      // 사진 피드로
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
  // 멤버 버튼 리스트 생성
  List<Widget> _buildMemberButtons() {
    return _members.map((member) {
      final isSelected = _selectedMember == member['id'];
      final profilePicture = member['profilePicturePath']; // 기본 이미지 설정
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              if (isSelected) {
                _selectedMember = null; // 해제
                _loadPhotos(); // 기본 API 호출
              } else {
                _selectedMember = member['id']; // 선택
                _selectedTag = null; // 태그 선택 해제
                _loadPhotos(member['id'].toString());
              }
            });
            _loadPhotos(member['id'].toString());
          },
          icon: CircleAvatar(
            radius: 12,
            backgroundImage: profilePicture != null && profilePicture.startsWith('http')
                ? NetworkImage(profilePicture)
                : const AssetImage('assets/images/profilebase.PNG') as ImageProvider,
          ),
          label: Text(
            member['name'],
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            backgroundColor: isSelected ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      );
    }).toList();
  }

  // 태그 버튼 리스트 생성
  List<Widget> _buildTagButtons() {
    return _tags.map((tag) {
      final isSelected =  _selectedTag == tag['label'];
      final tagFilter = _mapTagToFilter(tag['label']);
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              if (isSelected) {
                _selectedTag = null; // 해제
                _loadPhotos(); // 기본 API 호출
              } else {
                _selectedTag = tag['label']; // 선택
                _selectedMember = null; // 멤버 선택 해제
                _loadPhotos(tagFilter);
              }
            });
            _loadPhotos(tagFilter);
          },
          icon: Icon(
            tag['icon'],
            size: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
          label: Text(
            tag['label'],
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            backgroundColor: isSelected ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      );
    }).toList();
  }

//서버에서 가져오는 사진 데이터
  Map<String, List<Map<String, dynamic>>> _groupPhotosByDate() {
    final Map<String, List<Map<String, dynamic>>> groupedPhotos = {};
    for (var photo in _photos) {
      final date = photo['uploadDate'] != null
          ? '${photo['uploadDate'].year}-${photo['uploadDate'].month}-${photo['uploadDate'].day}'
          : 'Unknown Date';
      if (!groupedPhotos.containsKey(date)) {
        groupedPhotos[date] = [];
      }
      groupedPhotos[date]!.add(photo);
    }
    return groupedPhotos;
  }
  //사진 탭해서 크게 보기
  void _showPhotoDialog(BuildContext context, List<Map<String, dynamic>> photos, int initialIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return InteractiveViewer(
                    child: Image.network(
                      '${photo['fileUrl']}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  );
                },
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

//태그 필터 서버로 넘길 단어
String _mapTagToFilter(String tag) {
  switch (tag) {
    case '풍경':
      return 'sight';
    case '음식':
      return 'food';
    case '동물':
      return 'animal';
    default:
      return 'other';
  }
}
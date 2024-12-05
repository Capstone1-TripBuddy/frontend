import 'dart:async';
import 'package:flutter/material.dart';
import 'fetch_main.dart';

/// 사진 피드 페이지
class PhotoFeedPage extends StatefulWidget {
  final int groupId;
  final int userId;
  const PhotoFeedPage({super.key, required this.groupId, required this.userId});

  @override
  State<PhotoFeedPage> createState() => _PhotoFeedPageState();
}

class _PhotoFeedPageState extends State<PhotoFeedPage> {
  List<Map<String, dynamic>> _photoFeed = [];
  List<Map<String, dynamic>> _groupMembers = [];
  bool _isLoading = true;

  @override
  void initState(){
    super.initState();
    _loadPhotoActivities();
    _loadGroupMembers();
  }

  Future<void> _loadPhotoActivities() async {
    setState(() => _isLoading = true);

    try {
      final activities = await fetchPhotoActivities(groupId: widget.groupId);
      setState(() {
        _photoFeed = activities.map((activity) {
          final replies = activity['photoReplies'] as List<dynamic>;
          final comments = replies.map((reply) {
            return {
              'userId': reply['userId'],
              'content': reply['content'],
            };
          }).toList();

          return {
            'photoId': activity['photoId'],
            'likes': activity['totalBookmarks'],
            'comments': comments,
            'totalReplies': activity['totalReplies'],
            'imageUrl': activity['imageUrl'] ?? 'assets/images/background.jpg', // 수정 필요
            'isCommentsVisible': false,
          };
        }).where((photo) =>
        photo['likes'] > 0 || photo['totalReplies'] > 0) // 필터링 조건
        .toList();
      });
    } catch (e) {
      print('사진 활동 데이터를 불러오지 못했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGroupMembers() async {
    try {
      final members = await fetchGroupMembers(widget.groupId);
      setState(() {
        _groupMembers = members;
      });
    } catch (e) {
      print('그룹 멤버 데이터를 불러오지 못했습니다: $e');
    }
  }

  Map<String, String> _getMemberInfo(dynamic userId) {
    final member = _groupMembers.firstWhere(
          (member) => member['id'] == int.tryParse(userId.toString()),
    );
    if (member != null) {
      return {
        'name': member['name'] ?? 'Unknown',
        'profilePicturePath': member['profilePicturePath'] ?? '',
      };
    }
    return {'name': 'Unknown', 'profilePicturePath': ''};
  }

  void _toggleCommentsVisibility(int index) {
    setState(() {
      _photoFeed[index]['isCommentsVisible'] =
      !_photoFeed[index]['isCommentsVisible'];
    });
  }

  Future<Size> _getImageSize(String imageUrl) async {
    final Completer<Size> completer = Completer();
    final Image image = Image.network(imageUrl);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final myImage = info.image;
        completer.complete(Size(myImage.width.toDouble(), myImage.height.toDouble()));
      }),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          '사진 피드',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadPhotoActivities();
          await _loadGroupMembers();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount:  _photoFeed.length, // 예시 데이터 개수
                itemBuilder: (context, index) {
                  final feed = _photoFeed[index];
                  return _buildPhotoFeedItem(
                    context,
                    index,
                    feed['imageUrl'],
                    feed['likes'],
                    feed['totalReplies'],
                    feed['comments'],
                    feed['isCommentsVisible'],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPhotoFeedItem(
      BuildContext context,
      int index,
      String imageUrl,
      int likes,
      int totalReplies,
      List<dynamic> comments,
      bool isCommentsVisible,) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보
            const SizedBox(height: 12),
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Size>(
                future: _getImageSize(imageUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                  }
                  final aspectRatio = snapshot.data!.width / snapshot.data!.height;
                  return AspectRatio(
                    aspectRatio: aspectRatio, // 동적으로 계산된 비율
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // 좋아요와 댓글
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.blue),
                      onPressed: () => _toggleCommentsVisibility(index),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalReplies',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            // 댓글 펼치기
            if (isCommentsVisible)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments.map((comment) {
                    final memberInfo = _getMemberInfo(comment['userId']);
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: memberInfo['profilePicturePath']!
                              .isNotEmpty
                              ? NetworkImage(memberInfo['profilePicturePath']!)
                              : const AssetImage(
                              'assets/images/profilebase.PNG')
                          as ImageProvider,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memberInfo['name']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                comment['content'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

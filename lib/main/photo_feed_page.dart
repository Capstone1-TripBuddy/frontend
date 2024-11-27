import 'package:flutter/material.dart';

class PhotoFeedPage extends StatefulWidget {
  const PhotoFeedPage({super.key});

  @override
  State<PhotoFeedPage> createState() => _PhotoFeedPageState();
}

class _PhotoFeedPageState extends State<PhotoFeedPage> {
  final List<Map<String, dynamic>> _photoFeed = [
    {
      'userName': 'Sarah',
      'userAvatar': 'assets/images/background2.jpg',
      'timeAgo': '2 hours ago',
      'imageUrl': 'assets/images/background.jpg',
      'description':
      'Watching the sunset over the mountains while enjoying local wine. The colors were absolutely breathtaking!',
      'likes': 12,
      'comments': ['Beautiful!', 'Amazing shot!', 'Looks peaceful!'],
      'isCommentsVisible': false,
    },
    {
      'userName': 'Michael',
      'userAvatar': 'assets/images/background2.jpg',
      'timeAgo': '5 hours ago',
      'imageUrl': 'assets/images/background.jpg',
      'description':
      'A misty forest that feels like another world. So serene and peaceful!',
      'likes': 8,
      'comments': ['So calming!', 'I want to go there too!'],
      'isCommentsVisible': false,
    },
  ];
  void _toggleCommentsVisibility(int index) {
    setState(() {
      _photoFeed[index]['isCommentsVisible'] =
      !_photoFeed[index]['isCommentsVisible'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Photo Feed',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount:  _photoFeed.length, // 예시 데이터 개수
        itemBuilder: (context, index) {
          final feed = _photoFeed[index];
          return _buildPhotoFeedItem(
            context,
            index,
            feed['userName'],
            feed['userAvatar'],
            feed['timeAgo'],
            feed['imageUrl'],
            feed['description'],
            feed['likes'],
            feed['comments'],
            feed['isCommentsVisible'],
          );
        },
      ),
    );
  }

  Widget _buildPhotoFeedItem(
      BuildContext context,
      int index,
      String userName,
      String userAvatar,
      String timeAgo,
      String imageUrl,
      String description,
      int likes,
      List<String> comments,
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
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(userAvatar),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            // 설명
            if (description.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.blue),
                  onPressed: () => _toggleCommentsVisibility(index),
                ),
              ],
            ),
            // 댓글 펼치기
            if (isCommentsVisible)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments
                      .map(
                        (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        comment,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

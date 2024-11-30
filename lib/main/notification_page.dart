import 'package:flutter/material.dart';

/// 여기
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'name': '홍길동',
        'time': '2 분 전',
        'action': '사진에 좋아요',
        'icon': Icons.favorite,
        'iconColor': Colors.red,
      },
      {
        'name': '장군이',
        'time': '1 시간 전',
        'action': '새 사진 업로드',
        'icon': Icons.photo,
        'iconColor': Colors.blue,
      },
      {
        'name': '장군이',
        'time': '3 시간 전',
        'action': '추억을 공유',
        'icon': Icons.chat_bubble,
        'iconColor': Colors.green,
      },
      {
        'name': '홍길동',
        'time': '5 시간 전',
        'action': '사진에 좋아요',
        'icon': Icons.favorite,
        'iconColor': Colors.red,
      },
      
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '알림',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: Icon(notification['icon'], color: notification['iconColor']),
            ),
            title: Text(
              '${notification['name']} : ${notification['action']}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              notification['time'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: TextButton(
              onPressed: () {
                // 알림 상세보기 로직
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text(
                'View',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          thickness: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }
}

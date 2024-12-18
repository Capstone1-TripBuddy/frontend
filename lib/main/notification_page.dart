import 'package:flutter/material.dart';
import 'fetch_main.dart';
import 'leave_memory_page.dart';


class NotificationPage extends StatefulWidget {
  final int groupId;
  final int userId;
  final List<Map<String, dynamic>> photos;
  const NotificationPage({super.key, required this.groupId, required this.userId, required this.photos});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final activities = await fetchGroupActivity(groupId: widget.groupId, userId: widget.userId);
      setState(() {
        _notifications = activities.map((activity) {
          final activityType = activity['activityType'];
          final actionText = _mapActivityTypeToText(activityType);

          return {
            'name': activity['userName'], // Replace with actual userName if available
            'time': _formatTime(activity['createdAt']),
            'action': actionText,
            'icon': _mapActivityTypeToIcon(activityType),
            'iconColor': _mapActivityTypeToColor(activityType),
            'activityType': activityType,
            'photoId': activity['photoId'], // 추가된 photoId
          };
        }).toList();
      });
    } catch (e) {
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('알림을 불러오지 못했습니다: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  String _mapActivityTypeToText(String activityType) {
    switch (activityType) {
      case 'share':
        return '님이 추억을 공유했어요!';
      case 'bookmark':
        return '님이 사진에 좋아요를 추가했어요!';
      case 'reply':
        return '님이 사진에 댓글을 추가했어요!';
      case 'upload':
        return '님의 업로드랑 분류가 끝났어요!';
      default:
        return '님이 활동을 했어요!';
    }
  }

  IconData _mapActivityTypeToIcon(String activityType) {
    switch (activityType) {
      case 'share':
        return Icons.share;
      case 'bookmark':
        return Icons.favorite;
      case 'reply':
        return Icons.comment;
      case 'upload':
        return Icons.upload;
      default:
        return Icons.notifications;
    }
  }

  Color _mapActivityTypeToColor(String activityType) {
    switch (activityType) {
      case 'share':
        return Colors.green;
      case 'bookmark':
        return Colors.blue;
      case 'reply':
        return Colors.pinkAccent;
      case 'upload':
        return Colors.deepOrangeAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String createdAt) {
    final dateTime = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 시간 전';
    } else {
      return '${difference.inDays} 일 전';
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadNotifications();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
            ? const Center(
                child: Text(
                  '최근 활동이 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  print(notification);
                  return ListTile(
                    onTap: notification['activityType'] == 'share'
                        ? () {
                      final photoId = notification['photoId'];
                      final photo = widget.photos.firstWhere(
                            (photo) => photo['photoId'] == photoId,
                        orElse: () => {},
                      );
                      if (photo.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveMemoryPage(
                              photo: {
                                'photoId': photo['photoId'],
                                'fileUrl': photo['fileUrl'],
                              },
                              groupId: widget.groupId,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('해당 사진을 찾을 수 없습니다.'),
                          ),
                        );
                      }
                    }
                        : null,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Icon(notification['icon'], color: notification['iconColor']),
                    ),
                    title: Text(
                      '${notification['name']} ${notification['action']}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      notification['time'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../notification/notification_overlay.dart';
import 'fetch_main.dart';

/// 좋아요 및 질문 3가지
class LeaveMemoryPage extends StatefulWidget {
  final Map<String, dynamic> photo;
  final int groupId;
  final int userId;

  const LeaveMemoryPage({super.key, required this.photo, required this.groupId, required this.userId,});

  @override
  State<LeaveMemoryPage> createState() => _LeaveMemoryPageState();
}

class _LeaveMemoryPageState extends State<LeaveMemoryPage> {
  late final NotificationService _notificationService;

  bool _isLiked = false;
  bool _isLoading = false; // 좋아요 버튼 로딩 상태
  bool _isSavingMemory = false;
  bool _isFetchingActivity = true;
  bool _isFetchingQuestions = true; // 질문 로딩 상태

  int? _bookmarkId;
  int? _replyId;
  String _responses = ''; // Store responses
  List<String> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadPhotoActivity();
    _fetchQuestions();
    _notificationService = NotificationService();

    // 알림 스트림 구독
    _notificationService.notificationStream.listen((message) {
      NotificationOverlayManager().show(context, message);
    });

    // 주기적으로 서버에서 알림 확인
    Timer.periodic(const Duration(seconds: 15), (_) {
      _notificationService.fetchNotifications(widget.groupId, widget.userId);
    });
  }

  Future<void> _loadPhotoActivity() async {
    setState(() => _isFetchingActivity = true);

    try {
      final activity = await fetchPhotoActivity(photoId: widget.photo['photoId']);

      setState(() {
        // 좋아요 데이터 초기화
        final bookmarks = activity['photoBookmarks'] as List<dynamic>;
        final userBookmark = bookmarks.firstWhere(
              (bookmark) => bookmark['userId'] == widget.userId,
          orElse: () => null,
        );
        if (userBookmark != null) {
          _isLiked = true;
          _bookmarkId = userBookmark['bookmarkId'];
        }
        // 댓글 데이터 초기화
        final replies = activity['photoReplies'] as List<dynamic>;
        if (replies.isNotEmpty) {
          _replyId = replies.first['replyId'];
          _responses = replies.first['replyText'];
        }
      });
    } catch (e) {
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('활동 정보를 불러오지 못했습니다: $e')),
      );
    } finally {
      setState(() => _isFetchingActivity = false);
    }
  }

  Future<void> _fetchQuestions() async {
    setState(() => _isFetchingQuestions = true);

    try {
      final questions = await fetchPhotoQuestions(photoId: widget.photo['photoId']);

      setState(() {
        _questions = questions.map<String>((q) => q['content'].toString()).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('질문을 가져오지 못했습니다: $e')),
      );
    } finally {
      setState(() => _isFetchingQuestions = false);
    }
  }
  Future<void> _toggleLike() async {
    setState(() => _isLoading = true);

    try {
      if (_isLiked) {
        // 좋아요를 취소하는 경우
        if (_bookmarkId == null) throw Exception("북마크 ID가 없습니다.");

        await deleteBookmark(bookmarkId: _bookmarkId!);

        setState(() {
          _isLiked = false;
          _bookmarkId = null; // 북마크 ID 초기화
        });
        if(!mounted)return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("북마크가 성공적으로 삭제되었습니다!")),
        );
      } else {
        // 좋아요를 추가하는 경우
        final bookmarkId = await addBookmark(
          groupId: widget.groupId,
          userId: widget.userId,
          photoId: widget.photo['photoId'],
        );

        setState(() {
          _isLiked = true;
          _bookmarkId = bookmarkId; // 받은 bookmarkId 저장
        });
        if(!mounted)return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("북마크가 성공적으로 추가되었습니다!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("북마크 추가 실패: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _saveResponses() async {
    setState(() => _isSavingMemory = true);

    try {
      if (_responses.isEmpty && _replyId != null) {
        // 텍스트 필드가 비어 있고 댓글이 이미 존재하는 경우 삭제 요청
        await deletePhotoMemory(replyId: _replyId!);

        setState(() {
          _replyId = null; // 댓글 ID 초기화
        });
        if(!mounted)return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("댓글이 성공적으로 삭제되었습니다!")),
        );
      } else if (_responses.isNotEmpty) {
        // 텍스트 필드가 비어 있지 않은 경우 저장 요청
        final replyId = await savePhotoMemory(
          groupId: widget.groupId,
          userId: widget.userId,
          photoId: widget.photo['photoId'],
          content: _responses,
        );

        setState(() {
          _replyId = replyId; // 저장된 댓글 ID
        });
        if(!mounted)return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("추억이 성공적으로 저장되었습니다!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("요청 실패: $e")),
      );
    } finally {
      setState(() => _isSavingMemory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    if (_isFetchingActivity) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("나의 추억"),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                  )
                  : Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo and details
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photo['fileUrl']!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 질문 섹션
            if (_isFetchingQuestions)
              const Text(
                "질문 생성 중...",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              )
            else if (_questions.isNotEmpty)
              for (var i = 0; i < _questions.length; i++) ...[
                Text(
                  "질문 ${i + 1}: ${_questions[i]}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
              ]
            else
              const Text(
                "질문이 없습니다.",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),

            TextField(
              controller: TextEditingController(text: _responses),
              onChanged: (value) => _responses = value,
              decoration: const InputDecoration(
                hintText: "이 사진과의 추억을 남겨보세요!",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isSavingMemory ? null : _saveResponses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSavingMemory
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text("저장", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
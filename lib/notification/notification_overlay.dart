import 'package:flutter/material.dart';
import 'dart:async';

import '../main/fetch_main.dart';

class NotificationOverlayManager {
  static final NotificationOverlayManager _instance = NotificationOverlayManager._internal();
  factory NotificationOverlayManager() => _instance;

  NotificationOverlayManager._internal();

  OverlayEntry? _overlayEntry;
  bool _isDisplaying = false;

  void show(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    if (_isDisplaying) return; // 이미 표시 중이면 무시

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    if (overlay != null) {
      _isDisplaying = true;
      overlay.insert(_overlayEntry!);

      // 일정 시간 후 알림 제거
      Future.delayed(duration, () {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isDisplaying = false;
      });
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final List<Map<String, dynamic>> _notifications = [];
  final StreamController<String> _notificationStreamController = StreamController.broadcast();

  Stream<String> get notificationStream => _notificationStreamController.stream;

  Future<void> fetchNotifications(int groupId, int userId) async {
    try {
      // 서버에서 새 알림 확인
      final newNotifications = await fetchGroupActivity(groupId: groupId, userId: userId);

      for (final notification in newNotifications) {
        if (!_notifications.contains(notification)) {
          _notifications.add(notification);
          // 새 알림 스트림으로 전송
          _notificationStreamController.add(notification['message']);
        }
      }
    } catch (e) {
      print("알림 가져오기 실패: $e");
    }
  }
}
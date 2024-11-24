import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  void setUserData(Map<String, dynamic> data) {
    _userData = data;
    notifyListeners(); // 상태 변경 알림
  }

  void clearUserData() {
    _userData = null;
    notifyListeners();
  }
}

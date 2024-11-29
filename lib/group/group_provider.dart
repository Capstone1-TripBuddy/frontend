import 'package:flutter/material.dart';

class GroupProvider with ChangeNotifier {
  Map<String, dynamic>? _groupData;

  Map<String, dynamic>? get groupData => _groupData;

  void setGroupData(Map<String, dynamic> data) {
    _groupData = data;
    notifyListeners();
  }
  void clearGroupData() {
    _groupData = null;
    notifyListeners();
  }
}

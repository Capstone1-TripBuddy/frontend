import 'package:flutter/material.dart';

class GroupProvider with ChangeNotifier {
  Map<String, dynamic>? _groupData;

  Map<String, dynamic>? get groupData => _groupData;

  void setGroupData(Map<String, dynamic> data) {
    _groupData = data;
    notifyListeners();
  }
  void addGroup(Map<String, dynamic> group) {
    if (_groupData == null) {
      _groupData = {'joinedGroups': [group]};
    } else {
      _groupData!['joinedGroups'] ??= [];
      _groupData!['joinedGroups'].add(group);
    }
    notifyListeners();
  }

  void removeGroup(int index) {
    if (_groupData != null &&
        _groupData!['joinedGroups'] != null &&
        index < _groupData!['joinedGroups'].length) {
      _groupData!['joinedGroups'].removeAt(index);
      notifyListeners();
    }
  }
  void clearGroupData() {
    _groupData = null;
    notifyListeners();
  }
}

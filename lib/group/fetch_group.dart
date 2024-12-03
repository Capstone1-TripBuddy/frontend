import 'dart:convert';
import 'package:http/http.dart' as http;
import '/constants.dart';

/// 그룹 생성 요청 함수
Future<Map<String, dynamic>> createGroup(String groupName, int creatorId) async {
  try {
    final uri = Uri.parse('$serverUrl/api/groups');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupName': groupName,
        'creatorId': creatorId,
      }),
    );
    print('Response Data: ${response.body}');
    if (response.statusCode == 201) {
      // 그룹 생성 성공
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('그룹 생성에 실패했습니다. 요청을 확인하세요.');
    } else {
      throw Exception('알 수 없는 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('그룹 생성 요청 중 오류가 발생했습니다: $e');
  }
}
/// 그룹 참가 요청 함수
Future<Map<String, dynamic>> joinGroup(int userId, String inviteCode) async {
  try {
    final uri = Uri.parse('$serverUrl/api/groups/members');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'inviteCode': inviteCode,
      }),
    );

    if (response.statusCode == 201) {
      // 그룹 참가 성공
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      throw Exception('잘못된 초대 코드입니다.');
    } else {
      throw Exception('알 수 없는 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('그룹 참가 요청 중 오류가 발생했습니다: $e');
  }
}

///사용자의 참여한 전체 그룹 조회 with group_list페이지
Future<List<Map<String, dynamic>>> fetchUserGroups(int userId) async {
  final String url = '$serverUrl/api/groups/$userId';

  try {
    final response = await http.get(Uri.parse(url));
    print('Response Data: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((group) {
        return {
          'id': group['id'] ?? 0,
          'title': group['groupName'] ?? 'Untitled Group', // 기본값 설정
          'creator':{
            'userId': group['creator']?['userId'] ?? 0, // 기본값 설정
            'name': group['creator']?['name'] ?? 'Unknown',
          },
          'createdAt': group['createdAt'] != null
              ? DateTime.parse(group['createdAt'])
              : DateTime.now(), // 기본값 설정
        };
      }).toList();
    } else {
      throw Exception('Failed to load groups: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching user groups: $e');
  }
}
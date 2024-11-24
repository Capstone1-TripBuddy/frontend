import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverUrl = ''; // 서버 URL

/// 그룹 생성 요청 함수
Future<Map<String, dynamic>> createGroup(String groupName, int creatorId) async {
  try {
    final uri = Uri.parse('$serverUrl/api/groups/create');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupName': groupName,
        'creatorId': creatorId,
      }),
    );

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
    final uri = Uri.parse('$serverUrl/api/groups/join');
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
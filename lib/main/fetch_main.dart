import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverUrl = 'https://c610-58-236-125-163.ngrok-free.app';

Future<List<Map<String, dynamic>>> fetchPhotosByGroupId(int groupId, {String? tagFilter}) async {
  const String baseUrl = '$serverUrl/api/albums';
  final String url = tagFilter != null ? '$baseUrl/$groupId/$tagFilter' : '$baseUrl/$groupId';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((photo) {
        return {
          'fileName': photo['fileName'] ?? 'Unknown File',
          'fileUrl': photo['fileUrl'] ?? '',
          'imageSize': photo['imageSize'],
          'uploadDate': photo['uploadDate'] != null
              ? DateTime.parse(photo['uploadDate'])
              : DateTime.now(), // 기본값 설정
        };
      }).toList();
    } else if (response.statusCode == 404) {
      // 404 처리: 빈 리스트 반환
      return [];
    } else {
      throw Exception('Failed to load photos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching photos: $e');
  }
}
Future<List<Map<String, dynamic>>> fetchGroupMembers(int groupId) async {
  final String url = '$serverUrl/api/groups/members/$groupId';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((member) {
        return {
          'id': member['id'] ?? 0,
          'email': member['email'] ?? 'No email',
          'name': member['name'] ?? 'Unknown',
          'profilePicturePath': member['profilePicture'], // 기본 이미지
          'createdAt': member['createdAt'] ?? DateTime.now().toIso8601String(),
        };
      }).toList();
    } else {
      throw Exception('Failed to load group members: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching group members: $e');
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String serverUrl = 'https://6990-58-236-125-163.ngrok-free.app'; // 서버 URL

/// 서버에서 이미지를 가져오는 함수
Future<List<String>> fetchImages(String albumName) async {
  try {
    final response = await http.post(
      Uri.parse('$serverUrl/api/albums'), // 서버의 API 엔드포인트
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'albumName': albumName}), // 요청 본문에 albumName 추가
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body); // JSON 디코딩
      return data.map((url) => url as String).toList(); // URL 리스트로 변환
    } else {
      throw Exception('Failed to fetch images. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('이미지 fetch 실패: $e');
  }
}

/// 그룹 ID를 기반으로 앨범 데이터를 가져오는 함수
Future<List<Map<String, dynamic>>> fetchAlbumsByGroupId(int groupId) async {
  final uri = Uri.parse('$serverUrl/api/albums/$groupId');

  try {
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      // 서버에서 받아온 JSON 데이터를 파싱하여 리스트로 반환
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch albums. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching albums: $e');
  }
}
///사진을 업로드하는 함수
Future<bool> uploadImages(List<File> imageFiles, {required String groupId, required String creatorId}) async {
  try {
    final uri = Uri.parse('$serverUrl/api/photos/upload');
    var request = http.MultipartRequest('POST', uri);

    request.fields['groupId'] = groupId;
    request.fields['creatorId'] = creatorId;

    for (var file in imageFiles) {
      request.files.add(await http.MultipartFile.fromPath(
        'photos', // 서버에서 기대하는 필드 이름
        file.path,
      ));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to upload images. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error uploading images: $e');
  }
}
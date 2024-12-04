import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:external_path/external_path.dart';
import 'package:archive/archive_io.dart';
import '/constants.dart';

// 그룹 내 사진 조회
Future<Map<String, dynamic>> fetchPhotosByGroupId(int groupId, {String? tagFilter, int page = 0}) async {
  const String baseUrl = '$serverUrl/api/albums';
  final String url = tagFilter != null ? '$baseUrl/$groupId/$tagFilter/$page' : '$baseUrl/$groupId/$page';
  print(url);
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List content = data['content'] ?? [];
      print(data);
      return {
        'content': content.map((photo) {
          return {
            'photoId': photo['photoId'],
            'fileUrl': root + photo['fileUrl'],
            'uploadDate': photo['uploadDate'] != null ? DateTime.parse(photo['uploadDate']) : DateTime.now(),
          };
        }).toList(),
        'totalPages': data['totalPages'],
        'totalElements': data['totalElements'],
      };
    } else if (response.statusCode == 404) {
      // 404 처리: 빈 리스트 반환
      return {
        'content': [],
        'totalPages': 0,
        'totalElements': 0,
      };
    } else {
      throw Exception('Failed to load photos: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching photos: $e');
  }
}

//여행 그룹의 멤버들 정보 조회
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
          'profilePicturePath': root + (member['profilePicture'] ?? ''), // 기본 이미지
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

//다운로드
Future<void> downloadAlbumAndExtract({required int groupId, required String albumName,}) async {
  final String url = '$serverUrl/api/albums/$groupId/$albumName/download';

  try {
    // DCIM 폴더 가져오기
    final Directory? dcimDir = await _getDCIMDirectory();
    print(dcimDir);
    if (dcimDir == null) throw Exception('DCIM directory not found.');

    // 다운로드할 ZIP 파일 경로
    final String zipFilePath = '${dcimDir.path}/$albumName.zip';
    final File zipFile = File(zipFilePath);
    // 서버로부터 ZIP 파일 다운로드
    final response = await http.get(Uri.parse(url));
    print(response.body);
    // 디버깅용 로그
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      await zipFile.writeAsBytes(response.bodyBytes);
      print('ZIP file downloaded: $zipFilePath');

      // 압축 해제
      final String extractPath = '${dcimDir.path}/$albumName';
      await _extractZipFile(zipFilePath, extractPath);

      print('Files extracted to: $extractPath');

      // ZIP 파일 삭제 (선택적)
      await zipFile.delete();
      print('ZIP file deleted: $zipFilePath');
    } else if (response.statusCode == 404) {
      print('Album not found on server.');
    } else {
      throw Exception('Failed to download album: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during download or extraction: $e');
  }
}

//저장 장소 선정
Future<Directory?> _getDCIMDirectory() async {
  try {
    final String dcimPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DCIM);
    final Directory dcimDir = Directory(dcimPath);
    if (!await dcimDir.exists()) {
      await dcimDir.create(recursive: true);
    }
    return dcimDir;
  } catch (e) {
    print('Error getting DCIM directory: $e');
    return null;
  }
}

//집 파일 압축 해제
Future<void> _extractZipFile(String zipFilePath, String extractPath) async {
  try {
    final File zipFile = File(zipFilePath);

    // 압축 파일 열기
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 압축 해제
    for (final file in archive) {
      final String filePath = '$extractPath/${file.name}';
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }

    print('Extraction complete.');
  } catch (e) {
    print('Error extracting ZIP file: $e');
  }
}

//좋아요, 댓글 불러오기
Future<Map<String, dynamic>> fetchPhotoActivity({required int photoId}) async {
  final url = Uri.parse('$serverUrl/api/activity/photo/$photoId');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load photo activity: ${response.statusCode}');
  }
}

/// 사용자가 좋아요한 사진 가져오기
Future<List<Map<String, dynamic>>> fetchUserBookmarks(int userId) async {
  final url = Uri.parse('$serverUrl/api/activity/bookmark/user/$userId');
  try {
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((bookmark) => {
        'photoId': bookmark['photoId'],
        'createdAt': bookmark['createdAt'],
      }).toList();
    } else {
      throw Exception('Failed to fetch user bookmarks. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching user bookmarks: $e');
  }
}

///특정 사진 공유하기
Future<bool> sharePhoto({required int groupId, required int userId, required int photoId,}) async {
  final url = Uri.parse('$serverUrl/api/activity/share');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'groupId': groupId,
        'userId': userId,
        'photoId': photoId,
      }),
    );

    if (response.statusCode == 201) {
      print('공유 활동 성공');
      return true;
    } else {
      print('공유 활동 실패: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('서버 통신 오류: $e');
    return false;
  }
}
//좋아요 저장
Future<int?> addBookmark({required int groupId, required int userId, required int photoId,}) async {
  final url = Uri.parse('$serverUrl/api/activity/bookmark');
  final body = json.encode({
    "groupId": groupId,
    "userId": userId,
    "photoId": photoId,
  });
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: body,
  );
  if (response.statusCode == 201) {
    final responseData = jsonDecode(response.body);
    return responseData; // 서버에서 받은 bookmarkId 반환
  } else {
    throw Exception("Failed to add bookmark: ${response.body}");
  }
}

//좋아요 삭제
Future<void> deleteBookmark({required int bookmarkId}) async {
  final url = Uri.parse('$serverUrl/api/activity/bookmark/$bookmarkId');

  final response = await http.delete(url);

  if (response.statusCode != 204) {
    throw Exception('북마크 삭제 실패: ${response.statusCode}');
  }
}

//댓글 저장
Future<int> savePhotoMemory({required int groupId, required int userId, required int photoId, required String content,}) async {
  final url = Uri.parse('$serverUrl/api/activity/reply');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'groupId': groupId,
      'userId': userId,
      'photoId': photoId,
      'content': content,
    }),
  );

  if (response.statusCode == 201) {
    final replyId = int.parse(response.body); // replyId 반환
    return replyId;
  } else {
    throw Exception('Failed to save memory: ${response.statusCode}');
  }
}

//댓글 삭제
Future<void> deletePhotoMemory({required int replyId}) async {
  final url = Uri.parse('$serverUrl/api/activity/reply/$replyId');

  final response = await http.delete(url);

  if (response.statusCode != 204) {
    throw Exception('댓글 삭제 실패: ${response.statusCode}');
  }
}

///그룹 내 최신 활동 조회
Future<List<Map<String, dynamic>>> fetchGroupActivity({required int groupId, required int userId}) async {
  final url = Uri.parse('$serverUrl/api/activity/group/$groupId/user/$userId');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('Failed to load group activity: ${response.statusCode}');
  }
}

//AI 질문
Future<List<Map<String, dynamic>>> fetchPhotoQuestions({required int photoId}) async {
  final url = Uri.parse('$serverUrl/api/activity/question/$photoId');

  try {
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((q) => {
        'content': q['content'],
        'createdAt': q['createdAt'],
      }).toList();
    } else {
      throw Exception('Failed to fetch photo questions. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching photo questions: $e');
  }
}

//사진 피드 조회
Future<List<Map<String, dynamic>>> fetchPhotoActivities({required int groupId}) async {
  final url = Uri.parse('$serverUrl/api/activity/group/$groupId');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((activity) => {
        'photoId': activity['photoId'],
        'imageUrl': root + activity['photoUrl'], // 서버에서 제공하는 URL 매핑
        'totalBookmarks': activity['totalBookmarks'] ?? 0,
        'totalReplies': activity['totalReplies'] ?? 0,
        'photoReplies': activity['photoReplies'] ?? [],
        'photoQuestions': activity['photoQuestions'] ?? [],
      }).toList();
    } else {
      throw Exception('Failed to fetch photo activities. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching photo activities: $e');
  }
}
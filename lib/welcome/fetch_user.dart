import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

const String serverUrl = ''; // 서버 킬 때마다 최신화
/// 회원가입 요청 함수
Future<String> signUpUser(String name, String email, String password, File? profileImage) async {
  try {
    final uri = Uri.parse('$serverUrl/api/users/signup'); // API 엔드포인트

    // Multipart request 생성
    var request = http.MultipartRequest('POST', uri);

    // 텍스트 필드 추가
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;

    // 파일 필드 추가 (profilePicture)
    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profilePicture', // 서버에서 기대하는 필드 이름
        profileImage.path,
      ));
    }

    // 요청 전송 및 응답 처리
    var response = await request.send();

    if (response.statusCode == 201) {
      return '회원가입 성공';
    } else if (response.statusCode == 400) {
      return '유효하지 않은 요청 데이터입니다.';
    } else if (response.statusCode == 409) {
      return '이미 존재하는 이메일 주소입니다.';
    } else {
      return '알 수 없는 오류가 발생했습니다. 상태 코드: ${response.statusCode}';
    }
  } catch (e) {
    return '회원가입 요청 중 오류가 발생했습니다: $e';
  }
}
///로그인 요청 함수
Future<Map<String, dynamic>> loginUser(
    String email, String password, void Function(Map<String, dynamic>) onUserLoggedIn) async {
  try {
    final uri = Uri.parse('$serverUrl/api/users/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      onUserLoggedIn(userData); // Provider에 데이터 전달
      return userData;
    } else if (response.statusCode == 400) {
      throw Exception('유효하지 않은 요청 데이터입니다.');
    } else if (response.statusCode == 401) {
      throw Exception('이메일 또는 비밀번호가 일치하지 않습니다.');
    } else if (response.statusCode == 404) {
      throw Exception('해당 사용자를 찾을 수 없습니다.');
    } else {
      throw Exception('알 수 없는 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('로그인 요청 중 오류가 발생했습니다: $e');
  }
}


///프로필 사진 변경
Future<bool> updateUserProfile(int userId, File profilePicture) async {
  final url = Uri.parse('$serverUrl/api/users/profile');

  try {
    final request = http.MultipartRequest('POST', url)
      ..fields['userId'] = userId.toString()
      ..files.add(await http.MultipartFile.fromPath(
        'profilePicture',
        profilePicture.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final response = await request.send();

    if (response.statusCode == 202) {
      return true; // 프로필 수정 성공
    } else {
      print('Error: ${response.statusCode}');
      return false; // 요청 실패
    }
  } catch (e) {
    print('Error updating profile: $e');
    return false;
  }
}
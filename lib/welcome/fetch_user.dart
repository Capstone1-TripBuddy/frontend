import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverUrl = 'https://6990-58-236-125-163.ngrok-free.app'; // 서버 URL
/// 회원가입 요청 함수
Future<String> signUpUser(String name, String email, String password) async {
  try {
    final uri = Uri.parse('$serverUrl/api/users/signup'); // API 엔드포인트
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

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
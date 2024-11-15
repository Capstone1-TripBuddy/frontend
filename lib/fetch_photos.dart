import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

const String serverUrl = 'https://bb07-219-255-207-130.ngrok-free.app';

Future<List<Uint8List>> fetchCategoryImageBytes(String category) async {
  final response = await http.post(
    Uri.parse('$serverUrl/api/albums/download'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'category': category}),
  );
  print('Response body for category $category: ${response.body}');
  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);

      // JSON에 'images' 필드가 없거나 빈 경우
      if (data['images'] == null || data['images'].isEmpty) {
        print('No images available for category $category');
        return [];
      }

      List<String> base64Images = List<String>.from(data['images']);
      return base64Images.map((base64) => base64Decode(base64)).toList();
    } catch (e) {
      // JSON 파싱 중 오류가 발생한 경우 처리
      print('Error parsing JSON for category $category: $e');
      throw Exception('Invalid JSON format for category $category');
    }
  } else {
    throw Exception('Failed to load image bytes for category $category');
  }
}
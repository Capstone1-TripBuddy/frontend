import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverUrl = '';

Future<List<Map<String, dynamic>>> fetchAlbumsByGroupId(int groupId) async {
  try {
    final response = await http.get(
      Uri.parse('$serverUrl/api/albums/$groupId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((album) => Map<String, dynamic>.from(album)).toList();
    } else {
      throw Exception('Failed to fetch albums. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching albums: $e');
  }
}
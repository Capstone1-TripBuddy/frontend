import 'package:flutter/material.dart';
import 'minbak_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MinbakDetailPage extends StatefulWidget {
  final Minbak bnb;

  const MinbakDetailPage({super.key, required this.bnb});

  @override
  _MinbakDetailPageState createState() => _MinbakDetailPageState();
}

class _MinbakDetailPageState extends State<MinbakDetailPage> {
  Map<String, dynamic>? locationData;

  @override
  void initState() {
    super.initState();
    fetchLocationData();
  }

  Future<void> fetchLocationData() async {
    final apiUrl = 'https://api.example.com/location'; // 실제 API 주소로 변경
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        locationData = jsonDecode(response.body);
      });
    } else {
      // 오류 처리
      print('Failed to load location data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bnb.name),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.bnb.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Icon(
                      widget.bnb.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.bnb.isFavorite ? Colors.red : Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.bnb.toggleFavorite();
                      });
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bnb.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.phone, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(
                        '010-1234-5678', // 임시 전화번호
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '민박 위치',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  locationData == null
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text('위도: ${locationData!['latitude']}, 경도: ${locationData!['longitude']}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

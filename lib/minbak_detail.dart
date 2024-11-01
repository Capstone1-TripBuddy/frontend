import 'package:flutter/material.dart';
import 'minbak_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MinbakDetailPage extends StatefulWidget {
  final Minbak minbak;

  const MinbakDetailPage({super.key, required this.minbak});

  @override
  _MinbakDetailPageState createState() => _MinbakDetailPageState();
}

class _MinbakDetailPageState extends State<MinbakDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.minbak.name),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  'https://picsum.photos/200',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Icon(
                      widget.minbak.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.minbak.isFavorite ? Colors.red : Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.minbak.toggleFavorite();
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
                    widget.minbak.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        widget.minbak.tel, // 임시 전화번호
                        style: const TextStyle(
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
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text('위도: ${widget.minbak.lat}, 경도: ${widget.minbak.lon}'),
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

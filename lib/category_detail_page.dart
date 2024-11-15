import 'package:flutter/material.dart';
import 'dart:typed_data';

class CategoryDetailPage extends StatelessWidget {
  final String categoryName;
  final List<String> imageUrls;

  CategoryDetailPage({required this.categoryName, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName 카테고리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 세 개의 열로 사진을 표시
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
/*
class CategoryDetailPage extends StatelessWidget {
  final String categoryName;
  final List<Uint8List> imageBytesList;

  CategoryDetailPage({required this.categoryName, required this.imageBytesList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${categoryName} 카테고리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 두 개의 열로 사진을 표시
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: imageBytesList.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.memory(
                imageBytesList[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
*/
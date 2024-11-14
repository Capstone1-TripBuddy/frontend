import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _imageFiles = [];

  Future<void> pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _imageFiles = images.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> requestPermissions() async {
    if (await Permission.photos.request().isGranted) {
      await pickImages();
    } else {
      print('사진 접근 권한이 필요합니다.');
    }
  }

  Future<void> uploadImages(List<File> imageFiles) async {
    final uri = Uri.parse('https://your-server-url.com/upload'); //서버 주소 입력
    var request = http.MultipartRequest('POST', uri);

    for (var file in imageFiles) {
      request.files.add(await http.MultipartFile.fromPath(
        'images', // 서버에서 기대하는 필드 이름
        file.path,
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Upload successful');
    } else {
      print('Upload failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () async {
                await requestPermissions();
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Select Photos'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.grey,
                backgroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _imageFiles.isNotEmpty
                  ? GridView.builder(
                      itemCount: _imageFiles.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            _imageFiles[index],
                            fit: BoxFit.cover,
                          ),
                        );
                        },
              )
                  : const Center(
                      child: Text(
                        '선택된 사진이 없습니다.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                if (_imageFiles.isNotEmpty) {
                  await uploadImages(_imageFiles);
                } else {
                  print('업로드할 사진이 없습니다.');
                }
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Photos'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.grey,
                backgroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
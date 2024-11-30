import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';

const String serverUrl = ''; //서버 킬 때마다 최신화

class PhotoUploadPage extends StatefulWidget {
  final int groupId;
  final int userId;
  const PhotoUploadPage({super.key, required this.groupId, required this.userId});

  @override
  _PhotoUploadPageState createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _selectedImages = [];
  bool _isUploading = false;

  Future<void> pickImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages != null) {
      List<Map<String, dynamic>> imagesWithMetadata = [];
      for (var xfile in pickedImages) {
        File file = File(xfile.path);

        // EXIF 데이터에서 촬영 시간 추출
        String? takenAt = await _getTakenAt(file);

        imagesWithMetadata.add({
          'file': file,
          'takenAt': takenAt ?? 'Unknown', // 촬영 시간 없으면 기본값
        });
      }
      setState(() {
        _selectedImages = imagesWithMetadata;
      });
    }
  }

  Future<String?> _getTakenAt(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final tags = await readExifFromBytes(bytes);

      if (tags.containsKey('Image DateTime')) {
        return tags['Image DateTime']?.printable; // EXIF 촬영 시간
      } else if (tags.containsKey('EXIF DateTimeOriginal')) {
        return tags['EXIF DateTimeOriginal']?.printable;
      }
    } catch (e) {
      print('Error reading EXIF data: $e');
    }
    return null;
  }

  Future<void> requestPermissions() async {
    if (await Permission.photos.request().isGranted) {
      await pickImages();
    } else {
      print('사진 접근 권한이 필요합니다.');
    }
  }

  Future<void> uploadImages() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final uri = Uri.parse('$serverUrl/api/albums/upload');
      var request = http.MultipartRequest('POST', uri);
      request.fields['groupId'] = widget.groupId.toString();
      request.fields['userId'] = widget.userId.toString();

      for (var imageData in _selectedImages) {
        File file = imageData['file'];
        String takenAt = imageData['takenAt'];

        request.files.add(await http.MultipartFile.fromPath(
          'photos', // 서버에서 기대하는 필드 이름
          file.path,
        ));
        request.fields['takenAt'] = takenAt; // 촬영 시간 추가
      }

      var response = await request.send();
      print(response.statusCode);
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('사진이 성공적으로 업로드되었습니다!'),
        ));
        setState(() {
          _selectedImages.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('업로드 실패. 다시 시도해주세요.'),
        ));
      }
    } catch (e) {
      print('Error uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('업로드 중 오류가 발생했습니다.'),
      ));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  /*
  void _clearSelectedImages() {
    setState(() {
      _selectedImages.clear();
    });
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '사진 업로드',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '여행 사진을 업로드하세요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '소중한 여행의 순간을 공유해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    dashPattern: const [8, 4],
                    color: Colors.grey,
                    child: GestureDetector(
                      onTap: pickImages,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              '파일을 드래그하거나 클릭하여 업로드하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '최대 20MB까지 업로드 가능합니다',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedImages.isNotEmpty) ...[
                    const Text(
                      '선택된 사진 미리보기:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index]['file'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedImages.isNotEmpty
                          ? uploadImages
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: _selectedImages.isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        '사진 업로드',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
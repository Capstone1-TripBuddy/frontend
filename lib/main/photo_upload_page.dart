import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '/constants.dart';

class PhotoUploadPage extends StatefulWidget {
  final int groupId;
  final int userId;
  const PhotoUploadPage({super.key, required this.groupId, required this.userId});

  @override
  State<PhotoUploadPage> createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  List<Map<String, dynamic>> _selectedImages = [];
  bool _isUploading = false;

  Future<void> pickFolder() async {
    // 폴더 선택
    String? selectedFolder = await FilePicker.platform.getDirectoryPath();

    if (selectedFolder != null) {
      final directory = Directory(selectedFolder);
      List<Map<String, dynamic>> imagesWithMetadata = [];
      final files = directory.listSync();

      for (var file in files) {
        if (file is File && _isImage(file.path)) {
          String? takenAt = await _getFileCreationDate(file);
          print(file);
          print(takenAt);
          imagesWithMetadata.add({
            'file': file,
            'takenAt': takenAt ?? 'Unknown',
          });
        }
      }

      setState(() {
        _selectedImages = imagesWithMetadata;
      });
    }
  }

  bool _isImage(String path) {
    // 이미지 파일인지 확인
    final extensions = ['jpg', 'jpeg', 'png', 'gif'];
    final ext = path.split('.').last.toLowerCase();
    return extensions.contains(ext);
  }

  Future<String?> _getFileCreationDate(File file) async {
    try {
      final stat = await file.stat();
      return stat.changed.toIso8601String(); // 파일의 생성 날짜를 ISO 8601 형식으로 반환
    } catch (e) {
      print('Error getting file creation date: $e');
      return null;
    }
  }

  Future<void> uploadImages() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final uri = Uri.parse('$serverUrl/api/albums/upload');
      var request = http.MultipartRequest('POST', uri);

      // 그룹 ID 및 사용자 ID 추가
      request.fields['groupId'] = widget.groupId.toString();
      request.fields['userId'] = widget.userId.toString();
      List<String> takenAtList = [];
      // 파일 정보 추가
      for (var imageData in _selectedImages) {
        File file = imageData['file'];
        String takenAt = imageData['takenAt'];

        // 사진 파일 추가
        request.files.add(await http.MultipartFile.fromPath(
          'photos', // 서버에서 기대하는 필드 이름
          file.path,
        ));
        // 촬영 시간 추가
        takenAtList.add(takenAt);
      }
      request.fields['takenAt'] = takenAtList.join(',');
      print(request.fields);
      print(request.files);
      // 서버로 전송
      var response = await request.send();
      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('사진이 성공적으로 업로드되었습니다!'),
        ));
        setState(() {
          _selectedImages.clear();
        });
      } else {
        print('업로드 실패. 다시 시도해주세요.');
      }
    } catch (e) {
      print('Error uploading images: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

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
                      onTap: pickFolder,
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
                            Icon(Icons.folder_open, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              '폴더를 클릭하여 업로드하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
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

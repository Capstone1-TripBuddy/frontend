import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const String serverUrl = 'https://bb07-219-255-207-130.ngrok-free.app';

class PhotoUploadPage extends StatefulWidget {
  const PhotoUploadPage({super.key});

  @override
  _PhotoUploadPageState createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isUploading = false;

  Future<void> pickImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages != null) {
      setState(() {
        _selectedImages = pickedImages.map((xfile) => File(xfile.path)).toList();
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
    setState(() {
      _isUploading = true;
    });

    try {
      final uri = Uri.parse('$serverUrl/api/photos/upload');
      var request = http.MultipartRequest('POST', uri);

      request.fields['userId'] = '1';
      request.fields['groupId'] = '1';
      for (var file in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'photos', // 서버에서 기대하는 필드 이름
          file.path,
        ));
      }
      var response = await request.send();
      print(response.statusCode);
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
  void _clearSelectedImages() {
    setState(() {
      _selectedImages.clear();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 업로드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () async {
                await pickImages();
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('사진 선택'),
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
              child: _selectedImages.isNotEmpty
                  ? GridView.builder(
                      itemCount: _selectedImages.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            _selectedImages[index],
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
                if (_selectedImages.isNotEmpty) {
                  await uploadImages(_selectedImages);
                } else {
                  print('업로드할 사진이 없습니다.');
                }
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('업로드하기'),
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
/*
class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages != null) {
      setState(() {
        _selectedImages = pickedImages.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  Future<void> _uploadImages() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final uri = Uri.parse('$serverUrl/upload');
      var request = http.MultipartRequest('POST', uri);

      for (var file in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'images', // 서버에서 기대하는 필드 이름
          file.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('사진이 성공적으로 업로드되었습니다!'),
        ));
        setState(() {
          _selectedImages.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('업로드 실패. 다시 시도해주세요.'),
        ));
      }
    } catch (e) {
      print('Error uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('업로드 중 오류가 발생했습니다.'),
      ));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _clearSelectedImages() {
    setState(() {
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사진 업로드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.photo_library),
              label: Text('사진 선택'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_selectedImages.isNotEmpty) ...[
              Text(
                '선택된 이미지',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  itemCount: _selectedImages.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _clearSelectedImages,
                    icon: Icon(Icons.delete),
                    label: Text('초기화'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _selectedImages.isNotEmpty && !_isUploading ? _uploadImages : null,
                    icon: Icon(Icons.cloud_upload),
                    label: Text('사진 업로드'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Center(
                child: Text(
                  '선택된 사진이 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            if (_isUploading)
              Center(child: CircularProgressIndicator()), // 업로드 중 로딩 인디케이터
          ],
        ),
      ),
    );
  }
}
*/
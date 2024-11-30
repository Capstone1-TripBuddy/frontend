import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../welcome/user_provider.dart';
import '../welcome/fetch_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _newProfileImage; // 새로 선택된 프로필 이미지
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickNewProfileImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });

      // userProvider를 사용해 사용자 데이터 업데이트
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateUserData({'profilePicture': pickedFile.path});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 사진이 업데이트되었습니다.')),
      );
    }
  }
  Future<void> _uploadProfileImage(BuildContext context) async {
    if (_newProfileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 선택해주세요.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int? userId = userProvider.userData?['userId'];
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
      );
      setState(() {
        _isUploading = false;
      });
      return;
    }

    final success = await updateUserProfile(userId, _newProfileImage!);

    setState(() {
      _isUploading = false;
    });

    if (success) {
      userProvider.updateUserData({'profilePicture': _newProfileImage!.path});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 사진이 업데이트되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 사진 업로드에 실패했습니다.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userName = userProvider.userData?['name'];
    final String userEmail = userProvider.userData?['email'];
    final String? userProfile = userProvider.userData?['profilePicture'];
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _newProfileImage != null
                            ? FileImage(_newProfileImage!) // 새로 선택된 이미지
                            : (userProfile != null && userProfile.isNotEmpty
                            ? NetworkImage(userProfile) as ImageProvider
                            : const AssetImage('assets/images/profilebase.PNG')),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 30,
                        child: GestureDetector(
                          onTap: () => _pickNewProfileImage(context),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black,
                            child: Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isUploading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () => _uploadProfileImage(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: const Text(
                      '프로필 사진 저장',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
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

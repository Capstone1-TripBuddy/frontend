import 'package:flutter/material.dart';
import 'fetch_user.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '/constants.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false; // 로딩 상태

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || _profileImage == null) {
      showCustomSnackBar(context, '모든 필드를 채워주세요.');
      return;
    }

    if (password != confirmPassword) {
      showCustomSnackBar(context, '비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await signUpUser(name, email, password, _profileImage);

    setState(() {
      _isLoading = false;
    });
    /// 여기 수정하기
    if (result == '회원가입 성공') {
      showCustomSnackBar(context, '처음 뵙겠습니다!');
      Navigator.popUntil(context, ModalRoute.withName('/')); // 성공 시 이전 화면으로 이동
    }
  }

  //화면 넘어올 때마다 Controller 초기화
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/welcomebackground.jpg'), // 배경 이미지 파일 경로
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.popUntil(context, ModalRoute.withName('/'));
                          },
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            '당신의 여행을 시작하기 위한 회원가입',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomRight,
                                      end: Alignment.topLeft,
                                      colors: [
                                        Color(0xffF7FE2E),
                                        Color(0xffFA5882),
                                        Color(0xff2EFEC8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(70),
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 8,
                                  child: ElevatedButton(
                                    onPressed: _pickProfileImage,
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(8),
                                      backgroundColor: Colors.black,
                                    ),
                                    child: const Icon(Icons.upload, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 이름 입력 필드
                        const Text(
                          '이름',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: '홍길동',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 이메일 입력 필드
                        const Text(
                          '이메일',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 비밀번호 입력 필드
                        const Text(
                          '비밀번호',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Create a password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 비밀번호 확인 입력 필드
                        const Text(
                          '비밀번호 확인',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Confirm your password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 회원가입 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Icon(Icons.person_add, color: Colors.white),
                            label: const Text(
                              '회원가입',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 로그인 링크
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // 로그인 페이지로 이동
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              '이미 회원이신가요?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
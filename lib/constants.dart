import 'package:flutter/material.dart';

const String serverUrl = 'https://17db-58-236-125-163.ngrok-free.app'; //서버 킬 때마다 최신화
const String root = 'https://photo-bucket-012.s3.ap-northeast-2.amazonaws.com/'; //사진 url 시작부분

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 400, left: 16, right: 16),
      content: Text(message),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      duration: const Duration(seconds: 2), // 스낵바 표시 시간
    ),
  );
}
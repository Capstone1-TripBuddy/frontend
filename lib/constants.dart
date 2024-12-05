import 'package:flutter/material.dart';

const String serverUrl = 'https://9540-58-236-125-163.ngrok-free.app'; //서버 킬 때마다 최신화
const String root = 'https://photo-bucket-012.s3.ap-northeast-2.amazonaws.com/'; //사진 url 시작부분

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom:400, left: 30, right: 30),
      backgroundColor: Colors.white.withOpacity(0.9), // 반투명 흰색 배경
      elevation: 10,
      content: Text(
        message,
        style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize:14),
        textAlign: TextAlign.center,),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      duration: const Duration(seconds: 1), // 스낵바 표시 시간
    ),
  );
}
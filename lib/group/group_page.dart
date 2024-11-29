import 'package:flutter/material.dart';
import 'group_list_page.dart';


class GroupPage extends StatelessWidget{
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지 설정
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background2.jpg'), // 배경 이미지 파일 경로
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 반투명한 카드와 텍스트를 포함한 내용
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '우리의 여행',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // 그룹 생성 카드
                  GestureDetector(
                    onTap: () {
                      // 그룹 생성 페이지로 이동
                      // GroupPage에서 Create Group 버튼을 눌렀을 때 이동
                      Navigator.pushNamed(context, '/create_group');
                    },
                    child: Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(Icons.add_circle, size: 40, color: Colors.black),
                            SizedBox(height: 5),
                            Text(
                              '여행 생성',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '                                                            ',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 그룹 참가 카드
                  GestureDetector(
                    onTap: () {
                      // 그룹 참가 페이지로 이동
                      Navigator.pushNamed(context, '/join_group');
                    },
                    child: Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(Icons.vpn_key, size: 40, color: Colors.black),
                            SizedBox(height: 5),
                            Text(
                              '여행 참가',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '                                                            ',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 그룹 리스트 카드
                  GestureDetector(
                    onTap: () {
                      // 그룹 리스트 페이지로 이동
                      Navigator.pushNamed(context, '/group_list');
                    },
                    child: Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(Icons.featured_play_list_outlined, size: 40, color: Colors.black),
                            SizedBox(height: 5),
                            Text(
                              '여행 리스트',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '                                                            ',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_buddy/main/dashboard_page.dart';

import '../welcome/user_provider.dart';
import 'fetch_group.dart';
import 'group_provider.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final TextEditingController _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleJoinGroup() async {
    final inviteCode = _inviteCodeController.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드를 입력해주세요.')),
      );
      return;
    }

    final userId = userProvider.userData?['userId'];
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 없습니다. 다시 로그인 해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final groupData = await joinGroup(userId, inviteCode);

      if (!mounted) return;
      // 그룹 데이터 저장
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      groupProvider.setGroupData(groupData);
      groupProvider.addGroup(groupData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('그룹 "${groupData['groupName']}"에 참가했습니다!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(groupId: groupData['id'], userId: userId,)),
      );
       // 그룹 참가 완료 후 대쉬보드로 넘어가기
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('그룹 참가 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 배경색
      body: Center(
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
                  // 뒤로 가기 버튼
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/group'));
                    },
                  ),
                  const SizedBox(height: 8),
                  // 페이지 제목
                  const Center(
                    child: Text(
                      'Join Your Travel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 그룹 이름 입력 필드
                  const Text(
                    '초대 코드',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inviteCodeController,
                    decoration: InputDecoration(
                      hintText: 'Enter travel invite code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 그룹 참가 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:_isLoading ? null : _handleJoinGroup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: _isLoading ? Colors.grey : Colors.blue,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        '여행 참가',
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
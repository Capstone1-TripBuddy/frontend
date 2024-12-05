import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_buddy/group/fetch_group.dart';
import 'package:trip_buddy/group/group_provider.dart';
import 'package:trip_buddy/group/invite_code_page.dart';
import 'package:trip_buddy/welcome/user_provider.dart';


class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleCreateGroup() async {
    final groupName = _groupNameController.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행 이름을 입력해주세요.')),
      );
      return;
    }

    final creatorId = userProvider.userData?['userId'];
    if (creatorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 없습니다. 다시 로그인 해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final groupData = await createGroup(groupName, creatorId);
      if (!mounted) return;
      // 그룹 데이터 저장
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      groupProvider.setGroupData(groupData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹이 성공적으로 생성되었습니다!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InviteCodePage(inviteCode: groupData['inviteCode'], groupId: groupData['id']),
        ),
      );// 그룹 생성 완료 후 이전 페이지로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('그룹 생성 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 배경색
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background2.jpg'), // 배경 이미지 파일 경로
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
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
                          '새로운 여행',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 그룹 이름 입력 필드
                      const Text(
                        '여행 이름',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _groupNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter travel name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 24),
                      // 그룹 생성 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleCreateGroup,
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
                            '여행 생성',
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
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main/dashboard_page.dart';
import 'fetch_group.dart';
import '../welcome/user_provider.dart';
import 'group_provider.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userData?['userId'];
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final groups = await fetchUserGroups(userId);
      setState(() {
        _groups = groups;
      });
    } catch (e) {
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading groups: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  void _deleteGroup(BuildContext context, int index) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('그룹 삭제'),
            content: const Text('이 그룹을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  // 삭제 로직
                  setState(() {
                    _groups.removeAt(index); // 그룹 삭제
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('그룹이 삭제되었습니다.')),
                  );
                },
                child: const Text('삭제'),
              ),
            ],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userData?['userId'];
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
                            '같이 떠난 여행들',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(
                          color: Colors.grey, // 선 색상
                          thickness: 2.0,     // 선 두께
                        ),
                        // 그룹 리스트
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _groups.isNotEmpty
                            ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            return ListTile(
                              title: Text(
                                group['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                    
                                // 선택한 그룹 데이터를 가져옴
                                final selectedGroup = _groups.firstWhere(
                                      (g) => g['id'] == group['id'], // id로 그룹 데이터 비교
                                      orElse: () => {},
                                );
                    
                                if (selectedGroup != null) {
                                  // GroupProvider에 그룹 데이터 저장
                                  groupProvider.setGroupData({
                                    'id': selectedGroup['id'],
                                    'groupName': selectedGroup['title'], // title을 groupName으로 매핑
                                    'createdAt': selectedGroup['createdAt'],
                                    'inviteCode': selectedGroup['inviteCode'] ?? 'N/A', // inviteCode 없을 경우 기본값 설정
                                  });
                    
                                  // DashboardPage로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DashboardPage(
                                        groupId: group['id'] as int,
                                        userId: userId,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('그룹 데이터를 찾을 수 없습니다.')),
                                  );
                                }
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  _deleteGroup(context, index);
                                },
                              ),
                            );
                          },
                        )
                            : const Center(
                          child: Text(
                            '참가한 그룹이 없습니다.',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey),
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
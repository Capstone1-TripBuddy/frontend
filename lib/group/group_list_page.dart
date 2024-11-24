import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_buddy/dashboard.dart';
import 'group_provider.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {

  void _deleteGroup(
      BuildContext context, GroupProvider groupProvider, int index) {
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
                groupProvider.removeGroup(index); // 그룹 삭제
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
    final groupProvider = Provider.of<GroupProvider>(context);
    final groups = groupProvider.groupData?['joinedGroups'] ?? [];

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
                      'Travel List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 그룹 리스트
                  groups.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return ListTile(
                        title: Text(
                          group['groupName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // 대시보드로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DashboardPage(groupId: group['id'],)),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // 그룹 삭제 로직 추가
                            _deleteGroup(context, groupProvider, index);
                          },
                        ),
                      );
                    },
                  )
                      : const Center(
                        child: Text(
                          '참가한 그룹이 없습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
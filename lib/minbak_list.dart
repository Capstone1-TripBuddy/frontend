import 'package:flutter/material.dart';
import 'package:trip_buddy/minbak_detail.dart';
import 'minbak_model.dart';
import 'package:provider/provider.dart';
//민박 목록 페이지

class MinbakListPage extends StatelessWidget {
  const MinbakListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          //title: const Text('민박 목록 페이지'),
          title: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Container(
              color: Colors.transparent,
              height: 50.0,
              child: const TabBar(
                isScrollable: true,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4.0, color: Colors.orangeAccent), // 누른 곳 아래쪽 굵은 선
                ),
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                tabs: [
                  Tab(text: '전체'),
                  Tab(text: '경기'),
                  Tab(text: '강원'),
                  Tab(text: '충청'),
                  Tab(text: '경상'),
                  Tab(text: '전라'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            BnBFilterableList(region: '전체'),
            BnBFilterableList(region: '경기'),
            BnBFilterableList(region: '강원'),
            BnBFilterableList(region: '충청'),
            BnBFilterableList(region: '경상'),
            BnBFilterableList(region: '전라'),
          ],
        ),
      ),
    );
  }
}

class BnBFilterableList extends StatefulWidget {
  final String region;

  const BnBFilterableList({super.key, required this.region});

  @override
  _BnBFilterableListState createState() => _BnBFilterableListState();
}

class _BnBFilterableListState extends State<BnBFilterableList>{
  List<String> filters = ['굿스테이', '조식 제공', '와이파이', '에어컨'];
  List<bool> selectedFilters = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF0F2F2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
               child: Row(
                children: List<Widget>.generate(filters.length, (int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(filters[index]),
                      selected: selectedFilters[index],
                      onSelected: (bool selected) {
                        setState(() {
                          selectedFilters[index] = selected;
                        });
                      },
                      selectedColor: Colors.teal[300],
                      backgroundColor: Colors.teal[50],
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Minbak>>(
              future: fetchMinbaks(widget.region, selectedFilters), // 백엔드에서 데이터를 가져오는 Future 함수 호출
              builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('에러: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('민박 정보를 찾을 수 없습니다.'));
                } else {
                  List<Minbak> filteredMinbaks = snapshot.data!.where((minbak) {
                    switch (widget.region) {
                      case '경기':
                        return minbak.address.startsWith('경기');
                      case '강원':
                        return minbak.address.startsWith('강원');
                      case '충청':
                        return minbak.address.startsWith('충청');
                      case '경상':
                        return minbak.address.startsWith('경상');
                      case '전라':
                        return minbak.address.startsWith('전라');
                      case '제주':
                        return minbak.address.startsWith('제주');
                      default:
                        return true; // '전체' 지역의 경우 모든 데이터를 포함
                    }
                  }).toList();
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final minbak = snapshot.data![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        child: ListTile(
                          leading: Image.network(
                            'https://picsum.photos/200',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          title: Text(minbak.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //minbak.features.join(', ')
                              Row(
                                children: [
                                  if (minbak.internet) const Text('인터넷, '),
                                  if (minbak.breakfast) const Text('조식, '),
                                  if (minbak.goodstay) const Text('굿스테이'),
                                ],
                              ),
                              const Text('기타 정보들...'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              minbak.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: minbak.isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              setState(() {
                                minbak.toggleFavorite();
                              });
                            }
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => MinbakDetailPage(minbak: minbak),
                              )
                            );
                            // 민박 상세 페이지로 이동하는 코드 추가 가능
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


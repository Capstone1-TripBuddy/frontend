//찜 목록 페이지
import 'package:flutter/material.dart';
import 'minbak_detail.dart';
import 'minbak_model.dart';

/* 민박 리스트에서 찜을 한 것에 대한 목록을 보여줌
 찜 버튼을 눌러서 찜을 빼면 찜 목록에서도 삭제되면서 서버 db에서도
 이를 받아서 db 값에 찜을 no로 바꿔주게 해줌
 카드 형식은 민박 리스트랑 같고, 공유함.
 민박 리스트는 카테고리 따라 달라지는 것
 찜 리스트는 찜 유무에 따라 달라짐
 */
/*
class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Minbak>>(
        future: fetchFavoriteMinbaks(), // 찜한 민박들만 가져오는 Future 함수 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('찜한 민박이 없습니다.'));
          } else {
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
                        Row(
                          children: [
                            if (minbak.internet) const Text('인터넷'),
                            if (minbak.breakfast) const Text('조식'),
                            if (minbak.goodstay) const Text('굿스테이'),
                          ],
                        ), //bnb.features.join(', ')
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
    );
  }
}*/


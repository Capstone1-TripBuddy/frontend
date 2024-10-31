
class Minbak {
  //final int id;
  final String name;
  //final String address;
  //final String call;
  //final String category;
  //final double lat;
  //final double lon;
  //final bool card;
  final bool internet;
  final bool breakfast;
  final bool goodstay;
  final String imageUrl;
  bool isFavorite;

  Minbak({
    //required this.id,
    required this.name,
    //required this.address,
    //required this.call,
    //required this.category,
    //required this.lat,
    //required this.lon,
    //required this.card,
    required this.internet,
    required this.breakfast,
    required this.goodstay,
    required this.imageUrl,
    this.isFavorite = false,
  });
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
//민박 이미지만 따로
class MinbakImg {
  final int id;
  final int minbak_id;
  final String imageUrl;
  MinbakImg({
    required this.id,
    required this.minbak_id,
    required this.imageUrl,
});
}

Future<List<Minbak>> fetchBnBs(String region, List<bool> filters) async {
  await Future.delayed(const Duration(seconds: 1));
  return List.generate(
    10,
        (index) => Minbak(
      name: '$region 민박 $index',
      imageUrl: 'https://picsum.photos/200',
      internet: true,
      goodstay: true,
      breakfast: true,
      //features: ['굿스테이', '조식 제공', '와이파이'],
      isFavorite: false,
    ),
  );
}

Future<List<Minbak>> fetchFavoriteBnBs() async {
  await Future.delayed(const Duration(seconds: 1));
  return List.generate(
    5,
        (index) => Minbak(
      name: '찜한 민박 $index',
      imageUrl: 'https://picsum.photos/200',
          internet: true,
          goodstay: true,
          breakfast: true,
      //features: ['굿스테이', '조식 제공', '와이파이'],
      isFavorite: true,
    ),
  );
}
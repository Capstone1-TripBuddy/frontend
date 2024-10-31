
class BnB {
  final String name;
  final String imageUrl;
  final List<String> features;
  bool isFavorite;

  BnB({required this.name, required this.imageUrl, required this.features, this.isFavorite = false});
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}

Future<List<BnB>> fetchBnBs(String region, List<bool> filters) async {
  await Future.delayed(const Duration(seconds: 1));
  return List.generate(
    10,
        (index) => BnB(
      name: '$region 민박 $index',
      imageUrl: 'https://via.placeholder.com/150',
      features: ['와이파이', '취식 가능', '주차 가능'],
      isFavorite: false,
    ),
  );
}

Future<List<BnB>> fetchFavoriteBnBs() async {
  await Future.delayed(const Duration(seconds: 1));
  return List.generate(
    5,
        (index) => BnB(
      name: '찜한 민박 $index',
      imageUrl: 'https://via.placeholder.com/150',
      features: ['와이파이', '취식 가능', '주차 가능'],
      isFavorite: true,
    ),
  );
}
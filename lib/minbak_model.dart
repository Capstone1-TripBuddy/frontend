import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Minbak extends ChangeNotifier{
  final int id;
  final String name;
  final String address; // address 앞 글자 2글자 보고 판별
  final String tel;
  final String category;
  final double lat;
  final double lon;
  final bool card; //카드 결제 가능
  final bool internet;
  final bool breakfast;
  final bool goodstay;
  bool isFavorite;

  Minbak({
    required this.id,
    required this.name,
    required this.address,
    required this.tel,
    required this.category,
    required this.lat,
    required this.lon,
    required this.card,
    required this.internet,
    required this.breakfast,
    required this.goodstay,
    this.isFavorite = false,
  });
  factory Minbak.fromJson(Map<String, dynamic> json) {
    return Minbak(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      tel: json['tel'],
      category: json['category'],
      lat: json['lat'],
      lon: json['lon'],
      card: json['card'] == '0',
      internet: json['internet'] == '0',
      breakfast: json['breakfast'] == '0',
      goodstay: json['goodstay'] == '0',
    );
  }

  /*Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'tel': tel,
      'category': category,
      'lat': lat,
      'lon': lon,
      'card': card ? '1' : '0',
      'internet': internet ? '1' : '0',
      'breakfast': breakfast ? '1' : '0',
      'goodstay': goodstay ? '1' : '0',
    };
  }*/
  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
class MinbakProvider extends ChangeNotifier {
  List<Minbak> _minbakList = [];
  List<Minbak> get minbakList => _minbakList;

  void setBnBList(List<Minbak> list) {
    _minbakList = list;
    notifyListeners();
  }
  void toggleFavorite(Minbak minbak) {
    minbak.toggleFavorite();
    notifyListeners();
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

Future<List<Minbak>> fetchMinbaks(String region, List<bool> filters) async {
  const apiUrl = 'https://a435-219-255-207-131.ngrok-free.app/minbak/list'; // 서버 주소 with /minbak/list
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {"Content-Type": "application/json; charset=UTF-8"},);
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    // 데이터를 콘솔에 출력하여 확인합니다.
    return data.map((json) => Minbak.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load minbak data');
  }

}

/*
Future<List<Minbak>> fetchFavoriteMinbaks() async {
  await Future.delayed(const Duration(seconds: 1));
  return List.generate(
    5,
        (index) => Minbak(
          id: ,
          name: '찜한 민박 $index',
          address: '강원',
          internet: true,
          goodstay: true,
          breakfast: true,
      features: ['굿스테이', '조식 제공', '와이파이'],
      isFavorite: true,
    ),
  );
}
*/
import 'package:flutter/material.dart';
import 'package:trip_buddy/minbak_list.dart';
import 'package:trip_buddy/wish_list.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    MinbakListPage(),
    WishListPage(),
    // page 넣기
    // BnBListPage, WishListPage, AttractionListPage, ExperienceListPage
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(//4개
      backgroundColor: const Color(0xffF0F2F2),
      body: SafeArea(
          child: _widgetOptions.elementAt(_selectedIndex)
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: '민박',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '찜',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: '관광 명소',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hiking),
            label: '체험 관광',
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
import 'package:flutter/material.dart';
//import 'package:trip_buddy/minbak_list.dart';
//import 'package:trip_buddy/main_minbak_page.dart';
import 'addr_form_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        //scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 2,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const AddressFormPage(), // 나중에 splash page 추가
      //home: const MainPage(),
    );
  }
}

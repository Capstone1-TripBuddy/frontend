import 'package:flutter/material.dart';
import 'package:trip_buddy/dashboard.dart';
import 'package:trip_buddy/group/group_page.dart';
import 'package:trip_buddy/welcome/welcome_page.dart';
import 'category/categories.dart';

void main() {
  runApp(
    const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        //scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.grey[600]),
          elevation: 2,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
        //home: const DashboardPage(), //나중에 splash page 추가
      //home: const WelcomePage(),
      home: const GroupPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_buddy/main/dashboard_page.dart';
import 'package:trip_buddy/main/notification_page.dart';

import 'main/profile_page.dart';

import 'welcome/login_page.dart';
import 'welcome/user_provider.dart';
import 'welcome/welcome_page.dart';
import 'welcome/sign_up_page.dart';

import 'group/group_provider.dart';
import 'group/group_page.dart';
import 'group/create_group_page.dart';
import 'group/group_list_page.dart';
import 'group/join_group_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: const MyApp(),
    ),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/sign_up': (context) => const SignUpPage(),
        '/group': (context) => const GroupPage(),
        '/create_group': (context) => const CreateGroupPage(),
        '/join_group': (context) => const JoinGroupPage(),
        '/group_list': (context) => const GroupListPage(),
      },
        //splash page

    );
  }
}

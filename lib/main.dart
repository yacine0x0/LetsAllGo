import 'package:flutter/material.dart';
import 'package:flutter_project_1/views/dashboard/dashboard_page.dart';

import 'views/admin/users_page.dart';
import 'views/auth/login_page.dart';
import 'views/admin/analytics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      home: const LoginPage(),
    );
  }
}

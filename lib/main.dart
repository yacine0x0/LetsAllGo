import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'service/language_service.dart';
import 'controllers/profil/profil_controller.dart'; // ✅ ajouter
import 'views/auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageService>(
          create: (_) => LanguageService(),
        ),
        ChangeNotifierProvider<ProfileController>( // ✅ ajouter
          create: (_) => ProfileController(),
        ),
      ],
      child: MaterialApp(
        title: 'LetsAllGo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';                    // ← À AJOUTER

import 'service/language_service.dart';                   // ← À AJOUTER
import 'views/auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(                                 // ← Changement ici
      providers: [
        ChangeNotifierProvider<LanguageService>(
          create: (_) => LanguageService(),
        ),
        // Vous pourrez ajouter d'autres providers ici plus tard
      ],
      child: MaterialApp(
        title: 'Mon Application',
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
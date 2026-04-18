import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/language_service.dart';
import 'views/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService().loadTranslations(); // ✅ charger les traductions
  runApp(
    ChangeNotifierProvider<LanguageService>.value(
      value: LanguageService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LetsAllGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
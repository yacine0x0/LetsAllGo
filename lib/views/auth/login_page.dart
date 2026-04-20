// lib/views/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../service/language_service.dart';
import '../../controllers/auth/login_controller.dart';
import 'create_account_page.dart';
import '../dashboard/dashboard_page.dart';
import '../admin/admin_welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _controller.login(_emailCtrl.text, _passwordCtrl.text);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error == null) {
      final role = LoginController.currentUser?.role ?? 'etudiant';

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AdminWelcomePage(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } else {
      setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Fond principal
          Container(color: const Color.fromARGB(255, 89, 89, 189)),

          // Image de fond
          Opacity(
            opacity: 0.70,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Sélecteur de langue en haut à droite
          Positioned(
            top: h * 0.02,
            right: w * 0.02,
            child: _buildLanguageSelector(lang, h),
          ),

          // Contenu centré
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: h * 0.08),
                      Image.asset(
                        "assets/images/logo1_login.png",
                        width: h * 0.15,
                        height: h * 0.15,
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        "Let'sAllgo",
                        style: TextStyle(
                          fontSize: h * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Text(
                        lang.t(
                          "Apprenez les algorithmes étape par étape",
                          "Learn algorithms step by step with us",
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: h * 0.016,
                          color: const Color.fromARGB(246, 255, 255, 255),
                        ),
                      ),
                      SizedBox(height: h * 0.04),

                      // Carte de connexion
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
                          child: Container(
                            width: w * 0.35,
                            padding: EdgeInsets.symmetric(
                              horizontal: h * 0.04,
                              vertical: h * 0.09,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(Icons.lock_outline, size: h * 0.06, color: Colors.blue),
                                SizedBox(height: h * 0.02),

                                Text(
                                  lang.t("Connexion", "Login"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: h * 0.03,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 52, 52, 90),
                                  ),
                                ),
                                SizedBox(height: h * 0.01),

                                Text(
                                  lang.t(
                                    "Bonjour, bienvenue ! Connectez-vous à votre compte.",
                                    "Hi, welcome back! Please login to your account.",
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 249, 249, 250),
                                    fontSize: h * 0.014,
                                  ),
                                ),
                                SizedBox(height: h * 0.03),

                                // Champ Email
                                TextField(
                                  controller: _emailCtrl,
                                  style: TextStyle(color: Colors.white, fontSize: h * 0.016),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: lang.t("Email", "Email"),
                                    hintText: "exemple@gmail.com",
                                    hintStyle: TextStyle(
                                      color: const Color.fromARGB(255, 148, 144, 227),
                                      fontSize: h * 0.015,
                                    ),
                                    prefixIcon: Icon(Icons.email_outlined, size: h * 0.025),
                                    prefixIconColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: h * 0.02),

                                // Champ Mot de passe
                                TextField(
                                  controller: _passwordCtrl,
                                  style: TextStyle(color: Colors.white, fontSize: h * 0.016),
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: lang.t("Mot de passe", "Password"),
                                    hintText: lang.t("Entrez votre mot de passe", "Enter your password"),
                                    hintStyle: TextStyle(
                                      color: const Color.fromARGB(255, 148, 144, 227),
                                      fontSize: h * 0.015,
                                    ),
                                    prefixIcon: Icon(Icons.lock_outline, size: h * 0.025),
                                    prefixIconColor: Colors.white,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        size: h * 0.025,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: h * 0.015),

                                if (_errorMessage != null)
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red, fontSize: h * 0.014),
                                    textAlign: TextAlign.center,
                                  ),

                                SizedBox(height: h * 0.025),

                                // Bouton Connexion
                                SizedBox(
                                  height: h * 0.06,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            lang.t("Se connecter", "Login"),
                                            style: TextStyle(
                                              fontSize: h * 0.02,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: h * 0.02),

                                // Lien Créer un compte
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lang.t("Pas encore de compte ? ", "Don't have an account? "),
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 2, 17, 102),
                                        fontSize: h * 0.014,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CreateAccountPage()),
                                      ),
                                      child: Text(
                                        lang.t("Créer un compte", "Create an account"),
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: h * 0.014,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== SÉLECTEUR DE LANGUE ======================
  Widget _buildLanguageSelector(LanguageService lang, double h) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _langButton(
                flag: "🇫🇷",
                label: "FR",
                isSelected: lang.isFrench,
                h: h,
                onTap: () => context.read<LanguageService>().setFrench(),
              ),
              const SizedBox(width: 4),
              Container(width: 1, height: h * 0.03, color: Colors.white.withOpacity(0.3)),
              const SizedBox(width: 4),
              _langButton(
                flag: "🇬🇧",
                label: "EN",
                isSelected: !lang.isFrench,
                h: h,
                onTap: () => context.read<LanguageService>().setEnglish(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langButton({
    required String flag,
    required String label,
    required bool isSelected,
    required double h,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: h * 0.015, vertical: h * 0.008),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: TextStyle(fontSize: h * 0.022)),
            SizedBox(width: h * 0.006),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: h * 0.015,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

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
  static const String _baseUrl = 'http://localhost:3000/api';

  final LoginController       _controller   = LoginController();
  final TextEditingController _emailCtrl    = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final AudioPlayer           _audioPlayer  = AudioPlayer();

  bool    _isLoading       = false;
  bool    _obscurePassword = true;
  String? _errorMessage;

  // ══════════════════════════════════════════
  // SOUND — edit the file names here to change sounds
  // ══════════════════════════════════════════
  static const String _soundLoginButton  = 'sounds/PRESS_1.wav';
  static const String _soundToggleButton = 'sounds/PRESS_2.wav';

  Future<void> _playSound(String soundPath) async {
    await _audioPlayer.play(AssetSource(soundPath));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    await _playSound(_soundLoginButton);
    setState(() { _isLoading = true; _errorMessage = null; });

    final error = await _controller.login(
        _emailCtrl.text, _passwordCtrl.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      final role = LoginController.currentUser?.role ?? 'etudiant';
      if (role == 'admin') {
        Navigator.pushReplacement(context, PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AdminWelcomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DashboardPage()));
      }
    } else {
      setState(() => _errorMessage = error);
    }
  }

  void _showForgotPasswordDialog() {
    final lang = LanguageService();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ForgotPasswordDialog(
        lang:    lang,
        baseUrl: _baseUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final h    = MediaQuery.of(context).size.height;
    final w    = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color.fromARGB(255, 89, 89, 189)),
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

          Positioned(
            top:   h * 0.02,
            right: w * 0.02,
            child: _buildLanguageSelector(lang, h),
          ),

          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: h * 0.08),
                      Image.asset("assets/images/logo1_login.png",
                          width: h * 0.15, height: h * 0.15),
                      SizedBox(height: h * 0.005),
                      Text("Let'sAllgo",
                          style: TextStyle(
                              fontSize: h * 0.035,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: h * 0.01),
                      Text(
                        lang.t(
                          "Apprenez les algorithmes étape par étape",
                          "Learn algorithms step by step with us",
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: h * 0.016,
                            color: const Color.fromARGB(246, 255, 255, 255)),
                      ),
                      SizedBox(height: h * 0.04),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
                          child: Container(
                            width: w * 0.35,
                            padding: EdgeInsets.symmetric(
                                horizontal: h * 0.04, vertical: h * 0.06),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(Icons.lock_outline,
                                    size: h * 0.06, color: Colors.blue),
                                SizedBox(height: h * 0.02),
                                Text(
                                  lang.t("Connexion", "Login"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: h * 0.03,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                          255, 52, 52, 90)),
                                ),
                                SizedBox(height: h * 0.01),
                                Text(
                                  lang.t(
                                    "Bonjour, bienvenue ! Connectez-vous à votre compte.",
                                    "Hi, welcome back! Please login to your account.",
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 249, 249, 250),
                                      fontSize: h * 0.014),
                                ),
                                SizedBox(height: h * 0.03),

                                TextField(
                                  controller: _emailCtrl,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: h * 0.016),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    labelStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: h * 0.016),
                                    hintText: "exemple@gmail.com",
                                    hintStyle: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 148, 144, 227),
                                        fontSize: h * 0.015),
                                    prefixIcon: Icon(Icons.email_outlined,
                                        size: h * 0.025),
                                    prefixIconColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: h * 0.02),

                                TextField(
                                  controller: _passwordCtrl,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: h * 0.016),
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _handleLogin(),
                                  decoration: InputDecoration(
                                    labelText: lang.t("Mot de passe", "Password"),
                                    labelStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: h * 0.016),
                                    hintText: lang.t(
                                        "Entrez votre mot de passe",
                                        "Enter your password"),
                                    hintStyle: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 148, 144, 227),
                                        fontSize: h * 0.015),
                                    prefixIcon: Icon(Icons.lock_outline,
                                        size: h * 0.025),
                                    prefixIconColor: Colors.white,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: h * 0.025,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.white, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: h * 0.01),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: _showForgotPasswordDialog,
                                    child: Text(
                                      lang.t("Mot de passe oublié ?",
                                          "Forgot password?"),
                                      style: TextStyle(
                                        color: Colors.blue.shade200,
                                        fontSize: h * 0.013,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue.shade200,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: h * 0.02),

                                if (_errorMessage != null)
                                  Text(_errorMessage!,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: h * 0.014),
                                      textAlign: TextAlign.center),

                                SizedBox(height: h * 0.02),

                                SizedBox(
                                  height: h * 0.06,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : Text(
                                            lang.t("Entrer", "Enter"),
                                            style: TextStyle(
                                                fontSize: h * 0.02,
                                                color: Colors.white)),
                                  ),
                                ),
                                SizedBox(height: h * 0.02),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      lang.t(
                                          "Pas encore de compte ? ",
                                          "Don't have an account? "),
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 2, 17, 102),
                                          fontSize: h * 0.014),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const CreateAccountPage())),
                                      child: Text(
                                        lang.t("Créer un compte",
                                            "Create an account"),
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: h * 0.014),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.03),
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
            border: Border.all(
                color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _langButton(
                flag: "🇫🇷", label: "FR",
                isSelected: lang.isFrench, h: h,
                onTap: () {
                  _playSound(_soundToggleButton);
                  context.read<LanguageService>().setFrench();
                },
              ),
              const SizedBox(width: 4),
              Container(width: 1, height: 20,
                  color: Colors.white.withOpacity(0.3)),
              const SizedBox(width: 4),
              _langButton(
                flag: "🇬🇧", label: "EN",
                isSelected: !lang.isFrench, h: h,
                onTap: () {
                  _playSound(_soundToggleButton);
                  context.read<LanguageService>().setEnglish();
                },
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
        padding: EdgeInsets.symmetric(
            horizontal: h * 0.015, vertical: h * 0.008),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: TextStyle(fontSize: h * 0.022)),
            SizedBox(width: h * 0.006),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: h * 0.015,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// WIDGET DIALOG MOT DE PASSE OUBLIÉ — 3 étapes
// ══════════════════════════════════════════════════════
class _ForgotPasswordDialog extends StatefulWidget {
  final LanguageService lang;
  final String          baseUrl;

  const _ForgotPasswordDialog({
    required this.lang,
    required this.baseUrl,
  });

  @override
  State<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  int     _step    = 1;
  bool    _loading = false;
  String? _error;

  String _userId      = '';
  String _email       = '';
  String _verifiedOtp = '';

  final _emailCtrl    = TextEditingController();
  final _otpCtrl      = TextEditingController();
  final _newPassCtrl  = TextEditingController();
  final _confPassCtrl = TextEditingController();

  bool _obscureNew  = true;
  bool _obscureConf = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = widget.lang.t(
          'Email invalide', 'Invalid email'));
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body:    jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _email  = email;
        _userId = data['userId'] ?? '';
        setState(() { _step = 2; _loading = false; });
      } else {
        setState(() { _error = data['message'] ?? 'Erreur'; _loading = false; });
      }
    } catch (e) {
      setState(() {
        _error   = widget.lang.t('Impossible de contacter le serveur', 'Unable to contact server');
        _loading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = widget.lang.t(
          'Entrez le code à 6 chiffres', 'Enter the 6-digit code'));
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/auth/verify-reset-otp'),
        headers: {'Content-Type': 'application/json'},
        body:    jsonEncode({'userId': _userId, 'code': code}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _verifiedOtp = code;
        setState(() { _step = 3; _loading = false; });
      } else {
        setState(() { _error = data['message'] ?? 'Code invalide'; _loading = false; });
      }
    } catch (e) {
      setState(() {
        _error   = widget.lang.t('Impossible de contacter le serveur', 'Unable to contact server');
        _loading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final newPass  = _newPassCtrl.text;
    final confPass = _confPassCtrl.text;
    if (newPass.length < 6) {
      setState(() => _error = widget.lang.t('Minimum 6 caractères', 'Minimum 6 characters'));
      return;
    }
    if (newPass != confPass) {
      setState(() => _error = widget.lang.t(
          'Les mots de passe ne correspondent pas', 'Passwords do not match'));
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body:    jsonEncode({'userId': _userId, 'code': _verifiedOtp, 'newPassword': newPass}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.lang.t(
                '✅ Mot de passe réinitialisé !', '✅ Password reset successfully!')),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        setState(() { _error = data['message'] ?? 'Erreur'; _loading = false; });
      }
    } catch (e) {
      setState(() {
        _error   = widget.lang.t('Impossible de contacter le serveur', 'Unable to contact server');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h    = MediaQuery.of(context).size.height;
    final w    = MediaQuery.of(context).size.width;
    final lang = widget.lang;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width:       w * 0.32,
            constraints: const BoxConstraints(maxWidth: 480),
            padding:     const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color:        const Color(0xFF0D1B3E).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _step == 1 ? Icons.email_outlined
                            : _step == 2 ? Icons.pin_outlined
                            : Icons.lock_reset_outlined,
                        color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _step == 1
                            ? lang.t('Mot de passe oublié', 'Forgot Password')
                            : _step == 2
                            ? lang.t('Vérification', 'Verification')
                            : lang.t('Nouveau mot de passe', 'New Password'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: List.generate(3, (i) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _step ? Colors.blue : Colors.white24,
                        ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 1
                      ? _buildStep1(lang, h)
                      : _step == 2
                      ? _buildStep2(lang, h)
                      : _buildStep3(lang, h),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(LanguageService lang, double h) {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lang.t(
            'Entrez votre adresse email. Nous vous enverrons un code de vérification.',
            'Enter your email address. We will send you a verification code.',
          ),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 20),
        _field(ctrl: _emailCtrl, label: lang.t('Email', 'Email'),
            hint: 'exemple@gmail.com', icon: Icons.email_outlined,
            type: TextInputType.emailAddress),
        if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
        const SizedBox(height: 24),
        _actions(lang: lang, label: lang.t('Envoyer le code', 'Send Code'),
            color: Colors.blue, onConfirm: _sendCode),
      ],
    );
  }

  Widget _buildStep2(LanguageService lang, double h) {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lang.t('Un code à 6 chiffres a été envoyé à\n$_email',
              'A 6-digit code was sent to\n$_email'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontSize: 28,
              letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
        if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
        const SizedBox(height: 24),
        _actions(lang: lang, label: lang.t('Vérifier', 'Verify'),
            color: Colors.teal, onConfirm: _verifyOtp,
            showBack: true, onBack: () => setState(() { _step = 1; _error = null; })),
      ],
    );
  }

  Widget _buildStep3(LanguageService lang, double h) {
    return Column(
      key: const ValueKey(3),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lang.t('Créez un nouveau mot de passe sécurisé.',
              'Create a new secure password.'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 20),
        _field(ctrl: _newPassCtrl, label: lang.t('Nouveau mot de passe', 'New Password'),
            hint: '••••••••', icon: Icons.lock_outline, obscure: _obscureNew,
            suffix: IconButton(
              icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white38, size: 18),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            )),
        const SizedBox(height: 16),
        _field(ctrl: _confPassCtrl, label: lang.t('Confirmer le mot de passe', 'Confirm Password'),
            hint: '••••••••', icon: Icons.lock_reset_outlined, obscure: _obscureConf,
            suffix: IconButton(
              icon: Icon(_obscureConf ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white38, size: 18),
              onPressed: () => setState(() => _obscureConf = !_obscureConf),
            )),
        if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
        const SizedBox(height: 24),
        _actions(lang: lang, label: lang.t('Réinitialiser', 'Reset Password'),
            color: Colors.green, onConfirm: _resetPassword),
      ],
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? type,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: type,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.white38, size: 18),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorBox(String msg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red.withOpacity(0.4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg,
            style: const TextStyle(color: Colors.red, fontSize: 13))),
      ],
    ),
  );

  Widget _actions({
    required LanguageService lang,
    required String label,
    required Color color,
    required VoidCallback onConfirm,
    bool showBack = false,
    VoidCallback? onBack,
  }) {
    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            child: TextButton(
              onPressed: _loading ? null : onBack,
              child: Text(lang.t('Retour', 'Back'),
                  style: const TextStyle(color: Colors.white38)),
            ),
          ),
          const SizedBox(width: 8),
        ] else ...[
          Expanded(
            child: TextButton(
              onPressed: _loading ? null : () => Navigator.pop(context),
              child: Text(lang.t('Annuler', 'Cancel'),
                  style: const TextStyle(color: Colors.white38)),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _loading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _loading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
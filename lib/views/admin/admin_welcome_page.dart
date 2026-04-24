// lib/views/admin/admin_welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

import '../../service/language_service.dart';
import '../admin/admin_page.dart';
import '../auth/login_page.dart';

class AdminWelcomePage extends StatefulWidget {
  const AdminWelcomePage({super.key});

  @override
  State<AdminWelcomePage> createState() => _AdminWelcomePageState();
}

class _AdminWelcomePageState extends State<AdminWelcomePage> with TickerProviderStateMixin {
  late AnimationController _arrowCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _successCtrl;
  late AnimationController _shakeCtrl;
  late FocusNode _focusNode;

  final List<LogicalKeyboardKey> _secretCode = [
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowUp,
  ];

  List<LogicalKeyboardKey> _currentInput = [];
  bool _codeSuccess = false;
  bool _codeError = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _statusMessage = "Utilisez les flèches du clavier pour entrer la séquence secrète";

    _arrowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _successCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    _shakeCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || _codeSuccess) return;
    final key = event.logicalKey;

    if (![LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.arrowRight]
        .contains(key)) return;

    _handleKeyInput(key);
  }

  void _handleKeyInput(LogicalKeyboardKey key) {
    setState(() {
      _codeError = false;
      _currentInput.add(key);
      if (_currentInput.length > _secretCode.length) _currentInput.removeAt(0);

      if (_currentInput.length == _secretCode.length) {
        final isCorrect = _currentInput.asMap().entries.every((e) => e.value == _secretCode[e.key]);

        if (isCorrect) {
          _codeSuccess = true;
          _statusMessage = "✓ Accès autorisé — Bienvenue Administrateur";
          _successCtrl.forward();

          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) _navigateToAdmin();
          });
        } else {
          _codeError = true;
          _statusMessage = "✗ Séquence incorrecte — Veuillez réessayer";
          _shakeCtrl.forward(from: 0);

          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_codeSuccess) {
              setState(() {
                _currentInput.clear();
                _codeError = false;
                _statusMessage = "Utilisez les flèches du clavier pour entrer la séquence secrète";
              });
            }
          });
        }
      }
    });
  }

  void _navigateToAdmin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AdminPage(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _goBack() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF0D0D2B),
          child: Stack(
            children: [
              Opacity(
                opacity: 0.55,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/background_admin.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Bouton Retour
              Positioned(
                top: h * 0.04,
                left: w * 0.03,
                child: GestureDetector(
                  onTap: _goBack,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.015, vertical: h * 0.012),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: h * 0.022),
                        const SizedBox(width: 6),
                        Text(lang.t("Retour", "Back"),
                            style: TextStyle(color: Colors.white70, fontSize: h * 0.018)),
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: AnimatedBuilder(
                  animation: _shakeCtrl,
                  builder: (_, child) {
                    final shake = math.sin(_shakeCtrl.value * math.pi * 6) * 12 * (1 - _shakeCtrl.value);
                    return Transform.translate(offset: Offset(shake, 0), child: child);
                  },
                  child: Container(
                    width: w * 0.52,
                    padding: EdgeInsets.all(h * 0.06),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _codeSuccess
                            ? const Color(0xFF00FF9D).withValues(alpha: 0.6)
                            : _codeError
                                ? Colors.red.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.15),
                        width: 1.8,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) {
                            final glow = _codeSuccess ? 1.0 : _pulseCtrl.value;
                            return Container(
                              padding: EdgeInsets.all(h * 0.025),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _codeSuccess
                                    ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.06),
                                boxShadow: [
                                  BoxShadow(
                                    color: _codeSuccess
                                        ? const Color(0xFF00FF9D).withValues(alpha: glow * 0.4)
                                        : Colors.blue.withValues(alpha: glow * 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                size: h * 0.09,
                                color: _codeSuccess ? const Color(0xFF00FF9D) : Colors.white70,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: h * 0.04),
                        Text(
                          lang.t("VÉRIFICATION ADMINISTRATEUR", "ADMIN VERIFICATION"),
                          style: TextStyle(
                            fontSize: h * 0.032,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 5,
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: h * 0.018,
                            color: _codeSuccess
                                ? const Color(0xFF00FF9D)
                                : _codeError
                                    ? Colors.red.shade300
                                    : Colors.white54,
                            fontWeight: _codeSuccess ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: h * 0.06),
                        _buildProgressIndicators(h),
                        SizedBox(height: h * 0.08),
                        _buildActionButton(h, lang),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicators(double h) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final isEntered = i < _currentInput.length;
        final isCorrectSoFar = isEntered && _currentInput[i] == _secretCode[i];
        final isWrong = isEntered && !isCorrectSoFar;

        Color color = Colors.white24;
        if (_codeSuccess) color = const Color(0xFF00FF9D);
        else if (isWrong || (_codeError && isEntered)) color = Colors.red.shade400;
        else if (isEntered) color = Colors.blue;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: h * 0.008),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: h * 0.018,
            height: h * 0.018,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.8),
              border: Border.all(color: color, width: 1.5),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(double h, LanguageService lang) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        return Transform.scale(
          scale: _codeSuccess ? 1.02 : 1.0,
          child: GestureDetector(
            onTap: _codeSuccess ? _navigateToAdmin : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: h * 0.10, vertical: h * 0.028),
              decoration: BoxDecoration(
                color: _codeSuccess ? const Color(0xFF00FF9D).withValues(alpha: 0.25) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _codeSuccess ? const Color(0xFF00FF9D) : Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Text(
                _codeSuccess
                    ? lang.t("ENTRER DANS LE PANEL ADMIN", "ENTER ADMIN PANEL")
                    : lang.t("EN ATTENTE DE LA SÉQUENCE...", "WAITING FOR SEQUENCE..."),
                style: TextStyle(
                  color: _codeSuccess ? const Color(0xFF00FF9D) : Colors.white38,
                  fontSize: h * 0.019,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
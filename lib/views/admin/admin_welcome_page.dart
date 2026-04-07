// lib/views/admin/admin_welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../admin/admin_page.dart';
import '../auth/login_page.dart';

class AdminWelcomePage extends StatefulWidget {
  const AdminWelcomePage({super.key});

  @override
  State<AdminWelcomePage> createState() => _AdminWelcomePageState();
}

class _AdminWelcomePageState extends State<AdminWelcomePage>
    with TickerProviderStateMixin {

  late AnimationController _arrowCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _successCtrl;
  late AnimationController _shakeCtrl;
  late FocusNode _focusNode;

  // ── Code secret : ↑ ↓ → ← ↑  (invisible pour l'utilisateur)
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
  String _statusMessage = "Enter the secret sequence using arrow keys";

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
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

  // ─── Gestion du code secret (clavier uniquement) ────────────────────────
  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || _codeSuccess) return;

    final key = event.logicalKey;

    // On accepte uniquement les flèches
    final arrowKeys = [
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
    ];

    if (!arrowKeys.contains(key)) return;

    _handleKeyInput(key);
  }

  void _handleKeyInput(LogicalKeyboardKey key) {
    setState(() {
      _codeError = false;
      _currentInput.add(key);

      // On garde seulement les 5 dernières touches
      if (_currentInput.length > _secretCode.length) {
        _currentInput.removeAt(0);
      }

      // Vérification quand on a 5 touches
      if (_currentInput.length == _secretCode.length) {
        final isCorrect = _currentInput.asMap().entries
            .every((e) => e.value == _secretCode[e.key]);

        if (isCorrect) {
          _codeSuccess = true;
          _statusMessage = "✓ Access granted — Welcome, Administrator";
          _successCtrl.forward();

          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) _navigateToAdmin();
          });
        } else {
          _codeError = true;
          _statusMessage = "✗ Wrong sequence — Try again";
          _shakeCtrl.forward(from: 0);

          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_codeSuccess) {
              setState(() {
                _currentInput.clear();
                _codeError = false;
                _statusMessage = "Enter the secret sequence using arrow keys";
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
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
              // Background
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

              // Bouton Back
              Positioned(
                top: h * 0.04,
                left: w * 0.03,
                child: GestureDetector(
                  onTap: _goBack,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: w * 0.015, vertical: h * 0.012),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new,
                            color: Colors.white70, size: h * 0.022),
                        const SizedBox(width: 6),
                        Text("Back",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: h * 0.018)),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenu principal
              Center(
                child: AnimatedBuilder(
                  animation: _shakeCtrl,
                  builder: (_, child) {
                    final shake = math.sin(_shakeCtrl.value * math.pi * 6) *
                        12 *
                        (1 - _shakeCtrl.value);
                    return Transform.translate(
                        offset: Offset(shake, 0), child: child);
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
                      boxShadow: [
                        BoxShadow(
                          color: _codeSuccess
                              ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                              : _codeError
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.4),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icône admin
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
                                color: _codeSuccess
                                    ? const Color(0xFF00FF9D)
                                    : Colors.white70,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: h * 0.04),

                        // Titre
                        Text(
                          "ADMIN VERIFICATION",
                          style: TextStyle(
                            fontSize: h * 0.032,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 5,
                          ),
                        ),

                        SizedBox(height: h * 0.02),

                        // Message
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: h * 0.018,
                            color: _codeSuccess
                                ? const Color(0xFF00FF9D)
                                : _codeError
                                    ? Colors.red.shade300
                                    : Colors.white54,
                            fontWeight: _codeSuccess
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: h * 0.06),

                        // Indicateurs discrets (petits cercles sans flèches)
                        _buildProgressIndicators(h),

                        SizedBox(height: h * 0.08),

                        // Bouton principal (seulement actif en cas de succès)
                        _buildActionButton(h),
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

  // ─── Indicateurs de progression (petits cercles neutres) ─────────────────
  Widget _buildProgressIndicators(double h) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_secretCode.length, (i) {
        final isEntered = i < _currentInput.length;
        final isCorrectSoFar = isEntered && _currentInput[i] == _secretCode[i];
        final isWrong = isEntered && !isCorrectSoFar;

        Color color = Colors.white24;

        if (_codeSuccess) {
          color = const Color(0xFF00FF9D);
        } else if (isWrong || (_codeError && isEntered)) {
          color = Colors.red.shade400;
        } else if (isEntered) {
          color = Colors.blue;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: h * 0.008),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: h * 0.018,
            height: h * 0.018,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.8),
              border: Border.all(
                color: color,
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── Bouton principal ─────────────────────────────────────────────────────
  Widget _buildActionButton(double h) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        final scale = _codeSuccess ? 1.02 : 1.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: _codeSuccess ? _navigateToAdmin : null,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: h * 0.10, vertical: h * 0.028),
              decoration: BoxDecoration(
                color: _codeSuccess
                    ? const Color(0xFF00FF9D).withValues(alpha: 0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _codeSuccess
                      ? const Color(0xFF00FF9D)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Text(
                _codeSuccess ? "ENTER ADMIN PANEL" : "WAITING FOR SEQUENCE...",
                style: TextStyle(
                  color: _codeSuccess
                      ? const Color(0xFF00FF9D)
                      : Colors.white38,
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
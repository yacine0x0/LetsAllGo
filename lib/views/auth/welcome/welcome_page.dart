import 'package:flutter/material.dart';
import 'dart:async';
import '../../dashboard/dashboard_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  final List<String> _lines = [
    '> Initializing LetsAllgo...',
    '> Loading modules...',
    '',
    '> Welcome to LetsAllgo 🐺',
    '',
    '> We help you learn algorithms',
    '> step by step, in a fun way.',
    '',
    '> Learn. Practice. Master.',
    '',
    '> Ready ? Let\'s go ! 🚀',
  ];

  final List<String> _displayedLines = [];
  int _currentLine = 0;
  String _currentText = '';
  int _currentChar = 0;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startTyping();
  }

  void _startTyping() {
    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentLine >= _lines.length) {
        timer.cancel();
        setState(() => _showButton = true);
        return;
      }

      final line = _lines[_currentLine];

      if (line.isEmpty) {
        setState(() {
          _displayedLines.add('');
          _currentLine++;
          _currentText = '';
          _currentChar = 0;
        });
        return;
      }

      if (_currentChar < line.length) {
        setState(() {
          _currentText = line.substring(0, _currentChar + 1);
          _currentChar++;
        });
      } else {
        setState(() {
          _displayedLines.add(_currentText);
          _currentLine++;
          _currentText = '';
          _currentChar = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [

          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Positioned(
                top: h * 0.25 + _floatAnimation.value,
                left: w * 0.07,
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    "assets/images/masscott01.png",
                    width: 250,
                  ),
                ),
              );
            },
          ),

          Center(
            child: Container(
              width: w * 0.50,
              padding: EdgeInsets.all(h * 0.05),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      _dot(Colors.red),
                      SizedBox(width: w * 0.008),
                      _dot(Colors.orange),
                      SizedBox(width: w * 0.008),
                      _dot(Colors.green),
                      SizedBox(width: w * 0.02),
                      Text(
                        "letsallgo -- terminal",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: h * 0.014,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.03),

                  ...(_displayedLines.map((line) => Padding(
                        padding: EdgeInsets.only(bottom: h * 0.008),
                        child: Text(
                          line,
                          style: TextStyle(
                            color: _getColor(line),
                            fontSize: h * 0.02,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))),

                  if (_currentText.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          _currentText,
                          style: TextStyle(
                            color: _getColor(_currentText),
                            fontSize: h * 0.02,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _BlinkingCursor(height: h),
                      ],
                    ),

                  SizedBox(height: h * 0.04),

                  if (_showButton)
                    SizedBox(
                      width: double.infinity,
                      height: h * 0.06,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DashboardPage()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "> Get Started",
                          style: TextStyle(
                            fontSize: h * 0.02,
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String line) {
    if (line.startsWith('>')) return Colors.greenAccent;
    if (line.contains('Welcome')) return Colors.cyanAccent;
    if (line.contains('Ready')) return Colors.yellowAccent;
    return Colors.white70;
  }

  Widget _dot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final double height;
  const _BlinkingCursor({required this.height});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> {
  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _visible = !_visible);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: Text(
        '█',
        style: TextStyle(
          color: Colors.greenAccent,
          fontSize: widget.height * 0.02,
        ),
      ),
    );
  }
}
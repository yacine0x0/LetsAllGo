import 'dart:ui';
import 'package:flutter/material.dart';
import '../../controllers/auth/login_controller.dart';
import '../dashboard/dashboard_page.dart';
import 'create_account_page.dart';

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

    final error = await _controller.login(
      _emailCtrl.text,
      _passwordCtrl.text,
    );

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      // Naviguer vers Dashboard après login réussi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color.fromARGB(255, 89, 89, 189)),
          Opacity(
            opacity: 0.7,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background1.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: h * 0.05),
                        child: Image.asset(
                          "assets/images/logo1_login.png",
                          width: h * 0.15,
                          height: h * 0.15,
                        ),
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
                        "Learn algorithms in a fun way step by step",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: h * 0.016,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: h * 0.025),

                      // Carte login
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: h * 0.06,
                                  color: Colors.blue,
                                ),
                                SizedBox(height: h * 0.02),
                                Text(
                                  "Login",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: h * 0.03,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 52, 52, 90),
                                  ),
                                ),
                                SizedBox(height: h * 0.01),
                                Text(
                                  "Hi, welcome back please login to your account",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: h * 0.014,
                                  ),
                                ),
                                SizedBox(height: h * 0.03),

                                // Email
                                TextField(
                                  controller: _emailCtrl,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: h * 0.016,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: h * 0.016,
                                    ),
                                    hintText: "example@mail.com",
                                    hintStyle: TextStyle(
                                      color: Colors.blue[200],
                                      fontSize: h * 0.015,
                                    ),
                                    prefixIcon: Icon(Icons.email_outlined, size: h * 0.025, color: Colors.white),
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

                                // Password
                                TextField(
                                  controller: _passwordCtrl,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(color: Colors.white, fontSize: h * 0.016),
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(color: Colors.white, fontSize: h * 0.016),
                                    hintText: "Enter your password",
                                    hintStyle: TextStyle(color: Colors.blue[200], fontSize: h * 0.015),
                                    prefixIcon: Icon(Icons.lock_outline, size: h * 0.025, color: Colors.white),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        size: h * 0.025,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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

                                // Bouton login
                                SizedBox(
                                  height: h * 0.06,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            "Login",
                                            style: TextStyle(fontSize: h * 0.02, color: Colors.white),
                                          ),
                                  ),
                                ),
                                SizedBox(height: h * 0.02),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(color: Colors.white, fontSize: h * 0.014),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CreateAccountPage()),
                                      ),
                                      child: Text(
                                        "Create an account",
                                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: h * 0.014),
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
}
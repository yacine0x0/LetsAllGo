import 'package:flutter/material.dart';
import 'package:flutter_project_1/controllers/auth/create_account_controller.dart';
import 'package:flutter_project_1/controllers/auth/verify_account_controller.dart';

import 'login_page.dart';
import 'welcome/welcome_page.dart';

enum _AccountStep { createAccount, verifyAccount }

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final CreateAccountController _createController = CreateAccountController();
  late VerifyAccountController _verifyController;

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl   = TextEditingController();
  final TextEditingController _emailCtrl      = TextEditingController();
  final TextEditingController _passwordCtrl   = TextEditingController();
  final TextEditingController _pinCtrl        = TextEditingController();

  _AccountStep _currentStep     = _AccountStep.createAccount;
  bool         _isLoading       = false;
  bool         _obscurePassword = true;
  bool         _isVerified      = false;
  String?      _errorMessage;
  String?      _selectedGender;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final error = await _createController.createAccount(
      firstName: _firstNameCtrl.text,
      lastName:  _lastNameCtrl.text,
      email:     _emailCtrl.text,
      password:  _passwordCtrl.text,
      gender:    _selectedGender ?? '',
    );

    setState(() {
      _isLoading    = false;
      _errorMessage = error;
    });

    if (error == null) {
      _verifyController = VerifyAccountController(email: _emailCtrl.text);
      setState(() => _currentStep = _AccountStep.verifyAccount);
    }
  }

  Future<void> _handleVerifyPin() async {
    setState(() {
      _isLoading    = true;
      _errorMessage = null;
      _isVerified   = false;
    });

    final error = await _verifyController.verifyPin(_pinCtrl.text);

    setState(() {
      _isLoading    = false;
      _errorMessage = error;
      _isVerified   = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [

          Expanded(
            flex: 9,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/image_create_account.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 11,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _currentStep == _AccountStep.createAccount
                  ? _buildCreateAccountForm(h, w)
                  : _buildVerifyAccountForm(h, w),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildCreateAccountForm(double h, double w) {
    return Container(
      key: const ValueKey('createAccount'),
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.05),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Create Account",
              style: TextStyle(
                fontSize: h * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: h * 0.04),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _firstNameCtrl,
                    label: "First Name",
                    h: h,
                  ),
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  child: _buildField(
                    controller: _lastNameCtrl,
                    label: "Last Name",
                    h: h,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.025),

            _buildField(
              controller: _emailCtrl,
              label: "Email",
              h: h,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: h * 0.025),

            TextField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: TextStyle(fontSize: h * 0.018),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(fontSize: h * 0.016),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            SizedBox(height: h * 0.025),

            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              style: TextStyle(fontSize: h * 0.018, color: Colors.black87),
              decoration: InputDecoration(
                labelText: "Gender",
                labelStyle: TextStyle(fontSize: h * 0.016),
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "male",   child: Text("Male")),
                DropdownMenuItem(value: "female", child: Text("Female")),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            SizedBox(height: h * 0.015),

            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: h * 0.015),
              ),
            SizedBox(height: h * 0.03),

            SizedBox(
              width: double.infinity,
              height: h * 0.065,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: h * 0.02,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: h * 0.02),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account ? ",
                  style: TextStyle(color: Colors.grey, fontSize: h * 0.015),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: h * 0.015,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyAccountForm(double h, double w) {
    return Container(
      key: const ValueKey('verifyAccount'),
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.05),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            GestureDetector(
              onTap: () => setState(() {
                _currentStep  = _AccountStep.createAccount;
                _errorMessage = null;
                _isVerified   = false;
                _pinCtrl.clear();
              }),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black54),
                  SizedBox(width: w * 0.005),
                  Text(
                    "Back",
                    style: TextStyle(fontSize: h * 0.016, color: Colors.black54),
                  ),
                ],
              ),
            ),
            SizedBox(height: h * 0.03),

            Text(
              "Verify Account",
              style: TextStyle(
                fontSize: h * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: h * 0.015),

            Text(
              "A 6-digit PIN code has been sent to your email address.",
              style: TextStyle(fontSize: h * 0.016, color: Colors.black54),
            ),
            SizedBox(height: h * 0.04),

            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(fontSize: h * 0.022, letterSpacing: h * 0.01),
              decoration: InputDecoration(
                labelText: "Enter your PIN code",
                labelStyle: TextStyle(fontSize: h * 0.016),
                border: const OutlineInputBorder(),
                counterText: '',
                suffixIcon: _isVerified
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : (_errorMessage != null
                        ? const Icon(Icons.cancel, color: Colors.red)
                        : null),
              ),
            ),
            SizedBox(height: h * 0.02),

            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: h * 0.015),
              ),
            if (_isVerified)
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Verified successfully !",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: h * 0.016,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            SizedBox(height: h * 0.03),

            if (!_isVerified)
              SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Verify",
                          style: TextStyle(
                            fontSize: h * 0.02,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

            if (_isVerified) ...[
              SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomePage()),
                  ),
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    "Next",
                    style: TextStyle(fontSize: h * 0.02, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required double h,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: h * 0.018),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: h * 0.016),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
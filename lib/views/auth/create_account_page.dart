import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../service/language_service.dart';

import 'package:flutter_project_1/controllers/auth/create_account_controller.dart';
import 'package:flutter_project_1/controllers/auth/verify_account_controller.dart';

import 'login_page.dart';
import 'welcome/welcome_page.dart';
import '../../controllers/auth/login_controller.dart';
// (DashboardPage import pas nécessaire ici pour l’instant)

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
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();

  _AccountStep _currentStep = _AccountStep.createAccount;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isVerified = false;
  String? _errorMessage;
  String? _selectedGender;

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
    // Vérification des champs requis
    if (_firstNameCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = "Le prénom est requis / First name is required");
      return;
    }
    if (_lastNameCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = "Le nom est requis / Last name is required");
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      setState(() => _errorMessage = "Email valide requis / Valid email required");
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _errorMessage = "Le mot de passe doit contenir au moins 6 caractères / Password must be at least 6 characters");
      return;
    }
    if (_selectedGender == null) {
      setState(() => _errorMessage = "Veuillez sélectionner un genre / Please select a gender");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _createController.createAccount(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      gender: _selectedGender ?? '',
    );

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      _verifyController = VerifyAccountController(email: _emailCtrl.text.trim());
      setState(() => _currentStep = _AccountStep.verifyAccount);
    }
  }

  Future<void> _handleVerifyPin() async {
    final pin = _pinCtrl.text.trim();
    if (pin.length != 6) {
      setState(() => _errorMessage = "Le code PIN doit contenir 6 chiffres / PIN must be 6 digits");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isVerified = false;
    });

    final error = await _verifyController.verifyPin(pin);

    setState(() {
      _isLoading = false;
      _errorMessage = error;
      _isVerified = error == null;
    });
  }

  Future<String?> _autoLoginAfterVerify() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passwordCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      return "Veuillez vous connecter / Please login";
    }
    final controller = LoginController();
    return await controller.login(email, pass);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();

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
                  ? _buildCreateAccountForm(h, w, lang)
                  : _buildVerifyAccountForm(h, w, lang),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CREATE ACCOUNT FORM ====================
  Widget _buildCreateAccountForm(double h, double w, LanguageService lang) {
    return Container(
      key: const ValueKey('createAccount'),
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.05),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.t('Créer un compte', 'Create Account'),
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
                    label: lang.t('Prénom', 'First Name'),
                    h: h,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  child: _buildField(
                    controller: _lastNameCtrl,
                    label: lang.t('Nom', 'Last Name'),
                    h: h,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.025),

            _buildField(
              controller: _emailCtrl,
              label: lang.t('Email', 'Email'),
              h: h,
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            SizedBox(height: h * 0.025),

            TextField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: TextStyle(fontSize: h * 0.018),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              decoration: InputDecoration(
                labelText: lang.t('Mot De Passe', 'Password'),
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
                labelText: lang.t('Genre', 'Gender'),
                labelStyle: TextStyle(fontSize: h * 0.016),
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "male", child: Text("Male")),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        lang.t('Créer un compte', 'Create Account'),
                        style: TextStyle(fontSize: h * 0.02, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: h * 0.02),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  lang.t('Vous avez déjà un compte', 'Already have an account? '),
                  style: TextStyle(color: Colors.grey, fontSize: h * 0.015),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  child: Text(
                    lang.t('Connexion', 'Login'),
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

  // ==================== VERIFY ACCOUNT FORM ====================
  Widget _buildVerifyAccountForm(double h, double w, LanguageService lang) {
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
                _currentStep = _AccountStep.createAccount;
                _errorMessage = null;
                _isVerified = false;
                _pinCtrl.clear();
              }),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black54),
                  SizedBox(width: w * 0.005),
                  Text(
                    lang.t('Retour', 'Back'),
                    style: TextStyle(fontSize: h * 0.016, color: Colors.black54),
                  ),
                ],
              ),
            ),
            SizedBox(height: h * 0.03),

            Text(
              lang.t('Vérifier le compte', 'Verify Account'),
              style: TextStyle(
                fontSize: h * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: h * 0.015),

            Text(
              lang.t(
                'Un code de vérification a été envoyé à votre adresse email',
                'A 6-digit PIN code has been sent to your email address.',
              ),
              style: TextStyle(fontSize: h * 0.016, color: Colors.black54),
            ),
            SizedBox(height: h * 0.04),

            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(fontSize: h * 0.022, letterSpacing: h * 0.01),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleVerifyPin(),
              decoration: InputDecoration(
                labelText: lang.t('Code PIN', 'Enter the PIN code'),
                labelStyle: TextStyle(fontSize: h * 0.016),
                border: const OutlineInputBorder(),
                counterText: '',
                suffixIcon: _isVerified
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : (_errorMessage != null && _errorMessage != 'verification_reussie'
                        ? const Icon(Icons.cancel, color: Colors.red)
                        : null),
              ),
            ),
            SizedBox(height: h * 0.02),

            if (_errorMessage != null && !_isVerified)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: h * 0.015),
              ),

            if (_isVerified)
              Container(
                padding: EdgeInsets.symmetric(vertical: h * 0.01),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      lang.t('Vérification réussie !', 'Verified successfully!'),
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: h * 0.016,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
                          lang.t('Vérifier', 'Verify'),
                          style: TextStyle(fontSize: h * 0.02, color: Colors.white),
                        ),
                ),
              ),

            if (_isVerified)
              SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_isLoading) return;
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    final err = await _autoLoginAfterVerify();
                    if (!mounted) return;
                    setState(() => _isLoading = false);
                    if (err != null) {
                      setState(() => _errorMessage = err);
                      return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomePage()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    lang.t('Suivant', 'Next'),
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
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required double h,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: h * 0.018),
      textInputAction: TextInputAction.next,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: h * 0.016),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
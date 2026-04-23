import 'package:flutter/material.dart';
import 'package:flutter_project_1/controllers/auth/create_account_controller.dart';

import 'login_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final CreateAccountController _controller = CreateAccountController();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _selectedGender; // ← pour le sexe

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _controller.createAccount(
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      gender: _selectedGender ?? '',
    );

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      // Navigation vers login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [

          // ── Côté gauche — image
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

          // ── Côté droit — formulaire blanc
          Expanded(
            flex: 11,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.05,
                vertical: h * 0.05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Titre
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: h * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: h * 0.04),

                    // First Name + Last Name
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

                    // Email
                    _buildField(
                      controller: _emailCtrl,
                      label: "Email",
                      h: h,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: h * 0.025),

                    // Password
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.025),

                    // Gender
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      style: TextStyle(
                        fontSize: h * 0.018,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: "Gender",
                        labelStyle: TextStyle(fontSize: h * 0.016),
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "male", child: Text("Male")),
                        DropdownMenuItem(value: "female", child: Text("Female")),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                    ),
                    SizedBox(height: h * 0.015),

                    // Message erreur
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: h * 0.015,
                        ),
                      ),
                    SizedBox(height: h * 0.03),

                    // Bouton Create Account
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

                    // Lien login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account ? ",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: h * 0.015,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
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
            ),
          ),

        ],
      ),
    );
  }

  // Widget réutilisable pour les champs
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
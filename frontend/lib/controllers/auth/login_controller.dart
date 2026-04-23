import '../../../models/auth/login_model.dart';

class LoginController {
  Future<String?> login(String email, String password) async {
    final model = LoginModel(
      email: email.trim(),
      password: password,
    );

    final error = model.validate();
    if (error != null) return error;

    await Future.delayed(const Duration(seconds: 1));

    if (email.trim() == "admin@test.com" && password == "123456") {
      return null; // succès
    }

    return "Identifiants incorrects";
  }
}
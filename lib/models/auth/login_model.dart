class LoginModel {
  final String email;
  final String password;

  LoginModel({required this.email, required this.password});

  String? validate() {
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      return "Email invalide";
    }
    if (password.length < 6) {
      return "Le mot de passe doit contenir au moins 6 caractères";
    }
    return null;
  }
}
class CreateAccountModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String gender;

  CreateAccountModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.gender,
  });

  String? validate() {
    if (firstName.trim().length < 2) return "First name is too short";
    if (lastName.trim().length < 2) return "Last name is too short";
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      return "Invalid email";
    }
    if (password.length < 6) return "Password must be at least 6 characters";
    if (gender.isEmpty) return "Please select your gender";
    return null;
  }
}
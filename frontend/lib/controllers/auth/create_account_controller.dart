import '../../../models/auth/create_account_model.dart';

class CreateAccountController {
  Future<String?> createAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String gender,
  }) async {
    final model = CreateAccountModel(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      password: password,
      gender: gender,
    );

    final error = model.validate();
    if (error != null) return error;

    // Simulation appel API
    await Future.delayed(const Duration(seconds: 1));

    return null; // null = succès
  }
}
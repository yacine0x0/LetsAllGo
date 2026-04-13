import '../../models/auth/verify_account_model.dart';
import '../../service/auth/auth_services.dart';

class VerifyAccountController {
  final String email;

  VerifyAccountController({required this.email});

  Future<String?> verifyPin(String pin) async {
    final model = VerifyAccountModel(pin: pin);
    final error = model.validate();
    if (error != null) return error;

    return await AuthService.verifyEmail(
      email: email,
      code:  pin.trim(),
    );
  }
}
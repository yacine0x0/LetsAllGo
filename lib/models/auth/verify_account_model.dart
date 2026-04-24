class VerifyAccountModel {
  final String pin;
 
  VerifyAccountModel({required this.pin});
 
  String? validate() {
    if (pin.trim().isEmpty) return "Please enter your PIN code";
    if (pin.trim().length != 6 || int.tryParse(pin.trim()) == null) {
      return "PIN code must be exactly 6 digits";
    }
    return null;
  }
}
 
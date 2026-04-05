import '../../models/admin_models/profil_admin_model.dart';

class ProfileController {
  late ProfileModel model;

  ProfileController() {
    model = ProfileModel(
      firstName: "Zakaria",
      lastName: "Laadj",
      email: "zakaria.laadj@gmail.com",
    );
  }

  void updateFirstName(String value) => model.firstName = value;
  void updateLastName(String value) => model.lastName = value;
  void updateEmail(String value) => model.email = value;
  void toggleDarkMode(bool value) => model.isDarkMode = value;
  void updateLanguage(String value) => model.language = value;
}
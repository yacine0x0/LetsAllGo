class ProfileModel {
  String firstName;
  String lastName;
  String email;
  bool isDarkMode;
  String language;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.isDarkMode = true,
    this.language = "Français",
  });
}
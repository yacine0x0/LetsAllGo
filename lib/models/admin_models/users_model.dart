class UserItem {
  final int rank;
  final String firstName;
  final String lastName;
  final int totalPoints;
  bool isBlocked;

  UserItem({
    required this.rank,
    required this.firstName,
    required this.lastName,
    required this.totalPoints,
    this.isBlocked = false,
  });
}

class AdminModel {
  final List<UserItem> users;
  String searchQuery;

  AdminModel({
    required this.users,
    this.searchQuery = '',
  });

  // Utilisateurs filtrés selon la recherche
  List<UserItem> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    return users.where((u) =>
      u.firstName.toLowerCase().contains(searchQuery.toLowerCase()) ||
      u.lastName.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }
}
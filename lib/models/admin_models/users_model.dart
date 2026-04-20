class UserItem {
  final String id;      // 🆕 UUID depuis la BDD
  final int rank;
  final String firstName;
  final String lastName;
  final String email;
  final int totalPoints;
  bool isBlocked;

  UserItem({
    required this.id,
    required this.rank,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.totalPoints,
    this.isBlocked = false,
  });

  // 🆕 Depuis la BDD
  factory UserItem.fromApi(Map<String, dynamic> json) {
    return UserItem(
      id:          json['id']          as String,
      rank:        json['rank']        as int,
      firstName:   json['firstName']   as String,
      lastName:    json['lastName']    as String,
      email:       json['email']       as String,
      totalPoints: json['totalPoints'] as int,
    );
  }
}

class UsersModel {
  List<UserItem> users;
  String searchQuery;

  UsersModel({
    required this.users,
    this.searchQuery = '',
  });

  List<UserItem> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    final q = searchQuery.toLowerCase();
    return users.where((u) =>
      u.firstName.toLowerCase().contains(q) ||
      u.lastName.toLowerCase().contains(q)  ||
      u.email.toLowerCase().contains(q)
    ).toList();
  }
}
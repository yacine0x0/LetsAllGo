import '../../models/admin_models/users_model.dart';

class AdminController {
  late AdminModel model;

  AdminController() {
    model = AdminModel(
      users: [
        UserItem(
          rank: 1,
          firstName: "laadj",
          lastName: "Zakaria",
          totalPoints: 125,
        ),
        UserItem(
          rank: 2,
          firstName: "laarbi",
          lastName: "hamid",
          totalPoints: 120,
        ),
        UserItem(
          rank: 3,
          firstName: "kersani",
          lastName: "ilyas",
          totalPoints: 106,
        ),
        UserItem(
          rank: 4,
          firstName: "lebsir",
          lastName: "ali",
          totalPoints: 105,
        ),
        UserItem(
          rank: 5,
          firstName: "user5",
          lastName: "test",
          totalPoints: 98,
        ),
        UserItem(
          rank: 6,
          firstName: "user6",
          lastName: "test",
          totalPoints: 90,
        ),
        UserItem(
          rank: 7,
          firstName: "user7",
          lastName: "test",
          totalPoints: 85,
        ),
        UserItem(
          rank: 8,
          firstName: "user8",
          lastName: "test",
          totalPoints: 80,
        ),
      ],
    );
  }

  // Supprimer un utilisateur
  void deleteUser(int rank) {
    model.users.removeWhere((u) => u.rank == rank);
  }

  // Bloquer / débloquer un utilisateur
  void toggleBlock(int rank) {
    final user = model.users.firstWhere((u) => u.rank == rank);
    user.isBlocked = !user.isBlocked;
  }

  // Recherche
  void search(String query) {
    model.searchQuery = query;
  }
}

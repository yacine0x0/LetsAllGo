import 'package:flutter/material.dart';
import 'package:flutter_project_1/views/admin/analytics.dart';
import 'dart:ui';
import '../../controllers/admin_controllers/users_controller.dart';
import '../../models/admin_models/users_model.dart';
import '../../service/auth/LoginService.dart';
import '../admin/profil_admin_page.dart';
import '../auth/login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AdminController _controller = AdminController();
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedSidebarIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ✅ Charger les étudiants depuis la BDD
    _controller.loadUsers().then((_) {
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Confirmation suppression
  void _confirmDelete(BuildContext context, UserItem user, double h) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmer la suppression',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Voulez-vous vraiment supprimer ${user.firstName} ${user.lastName} ?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final error =
                  await _controller.deleteUser(user.id);
              if (error == null) {
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '✅ ${user.firstName} supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0D0D2B)),
          Opacity(
            opacity: 0.60,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background_admin.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildSidebar(h, w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(h, w),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.greenAccent))
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.02,
                                vertical: h * 0.02,
                              ),
                              child: _buildUsersTable(h, w),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── SIDEBAR
  Widget _buildSidebar(double h, double w) {
    final items = [
      {"icon": Icons.people, "label": "Users"},
      {"icon": Icons.bar_chart, "label": "Analytics"},
      {"icon": Icons.person, "label": "Profile"},
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: w * 0.09,
          color: Colors.black.withValues(alpha: 0.4),
          child: Column(
            children: [
              SizedBox(height: h * 0.02),
              Image.asset(
                "assets/images/icone_dash.png",
                width: h * 0.13,
                height: h * 0.13,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.school, color: Colors.blue, size: 40),
              ),
              SizedBox(height: h * 0.04),
              ...items.asMap().entries.map(
                (entry) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedSidebarIndex = entry.key);
                    if (entry.key == 2) {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProfilePage(),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween(
                                    begin: const Offset(0.0, 1.0),
                                    end: Offset.zero)
                                .chain(CurveTween(
                                    curve: Curves.easeInOut))
                                .animate(animation),
                            child: child,
                          );
                        },
                      ));
                    } else if (entry.key == 1) {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => AnalyticsPage(),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween(
                                    begin: const Offset(0.0, 1.0),
                                    end: Offset.zero)
                                .chain(CurveTween(
                                    curve: Curves.easeInOut))
                                .animate(animation),
                            child: child,
                          );
                        },
                      ));
                    }
                  },
                  child: _buildSidebarItem(
                    icon: entry.value["icon"] as IconData,
                    label: entry.value["label"] as String,
                    h: h,
                    isActive: _selectedSidebarIndex == entry.key,
                  ),
                ),
              ),
              const Spacer(),

              // ✅ Bouton Logout
              GestureDetector(
                onTap: () {
                  LoginService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: h * 0.02),
                  child: Column(
                    children: [
                      Icon(Icons.logout,
                          color: Colors.red, size: h * 0.04),
                      SizedBox(height: h * 0.005),
                      Text(
                        "Logout",
                        style: TextStyle(
                            color: Colors.red, fontSize: h * 0.015),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required double h,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 3,
          height: h * 0.07,
          decoration: BoxDecoration(
            color:
                isActive ? Colors.greenAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: h * 0.02),
            child: Column(
              children: [
                Icon(icon,
                    color: isActive
                        ? Colors.greenAccent
                        : Colors.white38,
                    size: h * 0.04),
                SizedBox(height: h * 0.005),
                Text(label,
                    style: TextStyle(
                      color: isActive
                          ? Colors.greenAccent
                          : Colors.white38,
                      fontSize: h * 0.015,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── HEADER
  Widget _buildHeader(double h, double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: w * 0.03, vertical: h * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A).withValues(alpha: 0.8),
        border: Border(
          bottom:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "User Management",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: h * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.008),
              Text(
                "Track student progress, manage accounts, and enhance algorithmic skills.",
                style: TextStyle(
                    color: Colors.white54, fontSize: h * 0.016),
              ),
            ],
          ),
          const Spacer(),

          // Search bar
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: w * 0.20,
                height: h * 0.055,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(
                      color: Colors.white, fontSize: h * 0.016),
                  onChanged: (value) {
                    setState(() => _controller.search(value));
                  },
                  decoration: InputDecoration(
                    hintText: "Search a user...",
                    hintStyle: TextStyle(
                        color: Colors.white38, fontSize: h * 0.016),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white38, size: h * 0.025),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: h * 0.015),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TABLE UTILISATEURS
  Widget _buildUsersTable(double h, double w) {
    final users = _controller.model.filteredUsers;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              _buildTableHeader(h, w),
              Container(height: 1, color: Colors.white12),
              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun étudiant trouvé',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: h * 0.018),
                        ),
                      )
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) =>
                            _buildUserRow(users[index], h, w),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(double h, double w) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: w * 0.03, vertical: h * 0.02),
      child: Row(
        children: [
          _headerCell("Rank",       w * 0.06, h),
          _headerCell("First Name", w * 0.14, h),
          _headerCell("Last Name",  w * 0.14, h),
          _headerCell("Email",      w * 0.18, h),
          _headerCell("Points",     w * 0.12, h),
          _headerCell("Action",     w * 0.15, h),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width, double h) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white60,
          fontSize: h * 0.016,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserRow(UserItem user, double h, double w) {
    final isTop3 = user.rank <= 3;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: w * 0.03, vertical: h * 0.018),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: w * 0.06,
            child: Text(
              '${user.rank}',
              style: TextStyle(
                color: isTop3 ? Colors.white : Colors.white54,
                fontSize: h * 0.018,
                fontWeight: isTop3
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),

          // First Name
          SizedBox(
            width: w * 0.14,
            child: Text(user.firstName,
                style: TextStyle(
                  color: isTop3 ? Colors.white : Colors.white54,
                  fontSize: h * 0.018,
                )),
          ),

          // Last Name
          SizedBox(
            width: w * 0.14,
            child: Text(user.lastName,
                style: TextStyle(
                  color: isTop3 ? Colors.white : Colors.white54,
                  fontSize: h * 0.018,
                )),
          ),

          // Email
          SizedBox(
            width: w * 0.18,
            child: Text(
              user.email,
              style: TextStyle(
                  color: Colors.white54, fontSize: h * 0.016),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Points
          SizedBox(
            width: w * 0.12,
            child: Text(
              '${user.totalPoints}',
              style: TextStyle(
                color: isTop3 ? Colors.greenAccent : Colors.white54,
                fontSize: h * 0.018,
                fontWeight: isTop3
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: w * 0.15,
            child: Row(
              children: [
                // ✅ Bouton supprimer avec confirmation
                GestureDetector(
                  onTap: () => _confirmDelete(context, user, h),
                  child: Container(
                    padding: EdgeInsets.all(h * 0.010),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.delete_outline,
                        color: Colors.red, size: h * 0.025),
                  ),
                ),
                SizedBox(width: w * 0.01),

                // Bouton bloquer/débloquer
                GestureDetector(
                  onTap: () {
                    setState(
                        () => _controller.toggleBlock(user.id));
                  },
                  child: Container(
                    padding: EdgeInsets.all(h * 0.010),
                    decoration: BoxDecoration(
                      color: user.isBlocked
                          ? Colors.orange.withValues(alpha: 0.15)
                          : Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: user.isBlocked
                            ? Colors.orange.withValues(alpha: 0.3)
                            : Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      user.isBlocked
                          ? Icons.person_off
                          : Icons.person_add,
                      color: user.isBlocked
                          ? Colors.orange
                          : Colors.blue,
                      size: h * 0.025,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
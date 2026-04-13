import 'package:flutter/material.dart';
import 'package:flutter_project_1/views/admin/analytics.dart';
import 'dart:ui';
import '../../controllers/admin_controllers/users_controller.dart';
import '../../models/admin_models/users_model.dart';
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(color: const Color(0xFF0D0D2B)),
            // 2. Image in background 
                   Opacity(
      opacity: 0.60, //pour que l'image soit plus sombre et que le texte ressorte mieux
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
              // ── Sidebar
              _buildSidebar(h, w),

              // ── Contenu principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Header
                    _buildHeader(h, w),

                    // Table
                    Expanded(
                      child: Padding(
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

    return ClipRRect(                          // ← ajouté
      child: BackdropFilter(                   // ← ajouté
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: w * 0.09,
          color: Colors.black.withValues(alpha: 0.4), // ← remplace Color(0xFF0A0A1A)
          
          child: Column(
            children: [
              SizedBox(height: h * 0.02),

              // Logo
              Image.asset(
                "assets/images/icone_dash.png",
                width: h * 0.13,
                height: h * 0.13,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.school,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              SizedBox(height: h * 0.04),

              // Items
             ...items.asMap().entries.map(
              (entry) => GestureDetector(
                 onTap: () {
                  setState(() => _selectedSidebarIndex = entry.key);

                   if (entry.key == 2) {
                      // TODO: Navigation vers AdminPage
                       Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); 
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ));
                       
                    } else if (entry.key == 1) {
                       Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => AnalyticsPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); 
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
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

              // ── Logout button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginPage(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: h * 0.03),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                        margin: EdgeInsets.only(bottom: h * 0.02),
                      ),
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.red.shade300,
                        size: h * 0.035,
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: h * 0.014,
                          fontWeight: FontWeight.w500,
                        ),
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
        // Ligne verte si actif
        Container(
          width: 3,
          height: h * 0.07,
          decoration: BoxDecoration(
            color: isActive ? Colors.greenAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: h * 0.02),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.greenAccent : Colors.white38,
                  size: h * 0.04,
                ),
                SizedBox(height: h * 0.005),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.greenAccent : Colors.white38,
                    fontSize: h * 0.015,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
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
        horizontal: w * 0.03,
        vertical: h * 0.03,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          // Titre
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
                  color: Colors.white54,
                  fontSize: h * 0.016,
                ),
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
                  style: TextStyle(color: Colors.white, fontSize: h * 0.016),
                  onChanged: (value) {
                    setState(() => _controller.search(value));
                  },
                  decoration: InputDecoration(
                    hintText: "Search an user...",
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: h * 0.016,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white38,
                      size: h * 0.025,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: h * 0.015),
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

              // En-tête table
              _buildTableHeader(h, w),

              // Ligne séparatrice
              Container(height: 1, color: Colors.white12),

              // Lignes utilisateurs
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _buildUserRow(users[index], h, w);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // En-tête de la table
  Widget _buildTableHeader(double h, double w) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.03,
        vertical: h * 0.02,
      ),
      child: Row(
        children: [
          _headerCell("Rank", w * 0.08, h),
          _headerCell("FirstName", w * 0.15, h),
          _headerCell("LastName", w * 0.15, h),
          _headerCell("TotalPoint", w * 0.15, h),
          _headerCell("ACTION", w * 0.15, h),
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

  // Ligne utilisateur
  Widget _buildUserRow(UserItem user, double h, double w) {
    final isTop3 = user.rank <= 3;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.03,
        vertical: h * 0.022,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: w * 0.08,
            child: Text(
              "${user.rank}",
              style: TextStyle(
                color: isTop3 ? Colors.white : Colors.white54,
                fontSize: h * 0.018,
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // FirstName
          SizedBox(
            width: w * 0.15,
            child: Text(
              user.firstName,
              style: TextStyle(
                color: isTop3 ? Colors.white : Colors.white54,
                fontSize: h * 0.018,
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // LastName
          SizedBox(
            width: w * 0.15,
            child: Text(
              user.lastName,
              style: TextStyle(
                color: isTop3 ? Colors.white : Colors.white54,
                fontSize: h * 0.018,
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // TotalPoints
          SizedBox(
            width: w * 0.15,
            child: Text(
              "${user.totalPoints}",
              style: TextStyle(
                color: isTop3 ? Colors.white : Colors.white54,
                fontSize: h * 0.018,
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: w * 0.15,
            child: Row(
              children: [

                // Bouton supprimer
                GestureDetector(
                  onTap: () {
                    setState(() => _controller.deleteUser(user.rank));
                  },
                  child: Container(
                    padding: EdgeInsets.all(h * 0.010),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: h * 0.025,
                    ),
                  ),
                ),
                SizedBox(width: w * 0.01),

                // Bouton bloquer/débloquer
                GestureDetector(
                  onTap: () {
                    setState(() => _controller.toggleBlock(user.rank));
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
                      user.isBlocked ? Icons.person_off : Icons.person_add,
                      color: user.isBlocked ? Colors.orange : Colors.blue,
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
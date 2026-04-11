import 'package:flutter/material.dart';
import 'package:flutter_project_1/views/admin/analytics.dart';
import 'dart:ui';
import '../../controllers/admin_controllers/admin_profil_controller.dart';
import '../admin/users_page.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  int _selectedSidebarIndex = 2; // ← Profile actif par défaut

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: _controller.model.firstName);
    _lastNameCtrl = TextEditingController(text: _controller.model.lastName);
    _emailCtrl = TextEditingController(text: _controller.model.email);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background couleur
          Container(color: const Color(0xFF0D0D2B)),

          // Background image
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

          // Contenu
          Row(
            children: [
              // ── Sidebar
              _buildSidebar(h, w),

              // ── Contenu principal
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(h * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Section informations personnelles
                      _buildPersonalInfo(h, w),
                      SizedBox(height: h * 0.04),

                      // Titre Paramètres
                      Text(
                        "Paramètres",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: h * 0.008),
                      Text(
                        "Personnalisez votre expérience et gérez votre compte.",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: h * 0.016,
                        ),
                      ),
                      SizedBox(height: h * 0.03),

                      // Section Apparence & Langue
                      _buildAppearanceSection(h, w),
                    ],
                  ),
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
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: w * 0.10,
          color: Colors.black.withValues(alpha: 0.5),
          child: Column(
            children: [
              SizedBox(height: h * 0.02),

              // Logo
              Image.asset(
                "assets/images/icone_dash.png",
                width: h * 0.13,
                height: h * 0.13,
                errorBuilder: (_, __, ___) => const Icon(
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
                    if (entry.key == 0) {
                      
                      

                        Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => AdminPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, -1.0); 
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
                        const begin = Offset(0.0, -1.0); 
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

  // ── INFORMATIONS PERSONNELLES
  Widget _buildPersonalInfo(double h, double w) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(h * 0.03),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Titre section
              Row(
                children: [
                  const Text("📝", style: TextStyle(fontSize: 20)),
                  SizedBox(width: w * 0.01),
                  Text(
                    "Informations personnelles",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.022,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: w * 0.01),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.03),

              // Prénom + Nom
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      value: _controller.model.firstName, // ← valeur directe
                      label: "PRÉNOM",
                      icon: Icons.person_outline,
                      h: h,
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  Expanded(
                    child: _buildInputField(
                      value: _controller.model.lastName, // ← valeur directe
                      label: "NOM",
                      icon: Icons.person_outline,
                      h: h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),

              // Email
              _buildInputField(
                value: _controller.model.email, // ← valeur directe
                label: "ADRESSE EMAIL",
                icon: Icons.email_outlined,
                h: h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String value,        
    required String label,
    required IconData icon,
    required double h,
        
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white54, size: h * 0.018),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white54,
                fontSize: h * 0.013,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        SizedBox(height: h * 0.008),

        // Container non modifiable
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: h * 0.015,
            vertical: h * 0.015,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.2), 
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),   // ← bordure discrète
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white70, // ← légèrement grisé
              fontSize: h * 0.018,
            ),
          ),
        ),
      ],
    );
  }
  // ── APPARENCE & LANGUE
  Widget _buildAppearanceSection(double h, double w) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(h * 0.03),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Titre
              Row(
                children: [
                  const Text("🎨", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    "Apparence & Langue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: h * 0.022,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.03),

              // Mode sombre
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mode sombre",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.018,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Passer entre le thème sombre et clair",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: h * 0.014,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Switch(
                    value: _controller.model.isDarkMode,
                    onChanged: (value) {
                      setState(() => _controller.toggleDarkMode(value));
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),

              // Divider
              Container(height: 1, color: Colors.white12),
              SizedBox(height: h * 0.025),

              // Langue
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Langue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: h * 0.018,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Choisissez votre langue préférée",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: h * 0.014,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Dropdown langue
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: h * 0.02,
                      vertical: h * 0.010,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButton<String>(
                      value: _controller.model.language,
                      dropdownColor: const Color(0xFF1A1A2E),
                      underline: const SizedBox(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: h * 0.016,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: "Français", child: Text("Français")),
                        DropdownMenuItem(value: "English", child: Text("English")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _controller.updateLanguage(value));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
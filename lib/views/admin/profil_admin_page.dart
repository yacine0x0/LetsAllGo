// lib/views/admin/profil_admin_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/admin_controllers/admin_profil_controller.dart';
import '../../service/language_service.dart';

import '../admin/admin_page.dart';     
import '../admin/analytics.dart';     
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

  int _selectedSidebarIndex = 2;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();

    _controller.loadProfile().then((_) {
      if (mounted) {
        setState(() {
          _firstNameCtrl.text = _controller.model.firstName;
          _lastNameCtrl.text = _controller.model.lastName;
          _emailCtrl.text = _controller.model.email;
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
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
              _buildSidebar(h, w, lang),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(h * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonalInfo(h, w, lang),
                      SizedBox(height: h * 0.04),
                      Text(
                        lang.t("Paramètres", "Settings"),
                        style: TextStyle(color: Colors.white, fontSize: h * 0.04, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: h * 0.008),
                      Text(
                        lang.t(
                          "Personnalisez votre expérience et gérez votre compte.",
                          "Customize your experience and manage your account.",
                        ),
                        style: TextStyle(color: Colors.white54, fontSize: h * 0.016),
                      ),
                      SizedBox(height: h * 0.03),
                      _buildAppearanceSection(h, w, lang),
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

  // ==================== SIDEBAR ====================
  Widget _buildSidebar(double h, double w, LanguageService lang) {
    final items = [
      {"icon": Icons.people, "label": lang.t("Utilisateurs", "Users")},
      {"icon": Icons.bar_chart, "label": lang.t("Analyses", "Analytics")},
      {"icon": Icons.person, "label": lang.t("Profil", "Profile")},
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
              Image.asset("assets/images/icone_dash.png", width: h * 0.13, height: h * 0.13),
              SizedBox(height: h * 0.04),

              ...items.asMap().entries.map(
                    (entry) => GestureDetector(
                      onTap: () {
                        setState(() => _selectedSidebarIndex = entry.key);
                        if (entry.key == 0) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const AdminPage()),
                          );
                        } else if (entry.key == 1) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                          );
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

              // Logout
              GestureDetector(
                onTap: _logout,
                child: Padding(
                  padding: EdgeInsets.only(bottom: h * 0.03),
                  child: Column(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent, size: h * 0.042),
                      SizedBox(height: h * 0.006),
                      Text(
                        lang.t("Déconnexion", "Logout"),
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: h * 0.015,
                          fontWeight: FontWeight.w600,
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
                Icon(icon, color: isActive ? Colors.greenAccent : Colors.white38, size: h * 0.04),
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

  // ==================== PERSONAL INFO ====================
  Widget _buildPersonalInfo(double h, double w, LanguageService lang) {
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
              Row(
                children: [
                  const Text("📝", style: TextStyle(fontSize: 20)),
                  SizedBox(width: w * 0.01),
                  Text(
                    lang.t("Informations personnelles", "Personal Information"),
                    style: TextStyle(color: Colors.white, fontSize: h * 0.022, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: h * 0.03),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      value: _controller.model.firstName,
                      label: lang.t("PRÉNOM", "FIRST NAME"),
                      icon: Icons.person_outline,
                      h: h,
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  Expanded(
                    child: _buildInputField(
                      value: _controller.model.lastName,
                      label: lang.t("NOM", "LAST NAME"),
                      icon: Icons.person_outline,
                      h: h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),
              _buildInputField(
                value: _controller.model.email,
                label: lang.t("ADRESSE EMAIL", "EMAIL ADDRESS"),
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
            const SizedBox(width: 6),
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
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: h * 0.015, vertical: h * 0.015),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            value.isNotEmpty ? value : "—",
            style: TextStyle(color: Colors.white70, fontSize: h * 0.018),
          ),
        ),
      ],
    );
  }

  // ==================== APPEARANCE & LANGUAGE ====================
  Widget _buildAppearanceSection(double h, double w, LanguageService lang) {
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
              Row(
                children: [
                  const Text("🎨", style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    lang.t("Apparence & Langue", "Appearance & Language"),
                    style: TextStyle(color: Colors.white, fontSize: h * 0.022, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: h * 0.03),

              // Langue
              Row(
                children: [
                  Text(lang.t("Langue", "Language"), style: TextStyle(color: Colors.white, fontSize: h * 0.018)),
                  const Spacer(),
                  DropdownButton<String>(
                    value: lang.isFrench ? "Français" : "English",
                    dropdownColor: const Color(0xFF1A1A2E),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: "Français", child: Text("Français")),
                      DropdownMenuItem(value: "English", child: Text("English")),
                    ],
                    onChanged: (value) {
                      final languageService = context.read<LanguageService>();
                      if (value == "Français") {
                        languageService.setFrench();
                      } else {
                        languageService.setEnglish();
                      }
                    },
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
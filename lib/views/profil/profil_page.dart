// lib/views/profil/profil_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../service/language_service.dart';
import '../../controllers/profil/profil_controller.dart';
import '../auth/login_page.dart';
import '../dashboard/dashboard_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../files/files_page.dart';
import '../quiz/quiz_selection_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.loadProfile().then((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════
  // DIALOGS
  // ══════════════════════════════════════════

  void _showEditNameDialog() {
    final m = _controller.model;
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    bool loading = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final lang = ctx.watch<LanguageService>();
          return _buildDialog(
            title: lang.t('Modifier le profil', 'Edit Profile'),
            icon: Icons.person_outline,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  ctrl: firstCtrl,
                  hint: m.firstName,
                  label: lang.t('Prénom', 'First Name'),
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _dialogField(
                  ctrl: lastCtrl,
                  hint: m.lastName,
                  label: lang.t('Nom', 'Last Name'),
                  icon: Icons.person_outline,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  _errorText(error!),
                ],
                const SizedBox(height: 24),
                _dialogActions(
                  ctx: ctx,
                  loading: loading,
                  confirmLabel: lang.t('Enregistrer', 'Save'),
                  onConfirm: () async {
                    final newFirst = firstCtrl.text.trim().isNotEmpty ? firstCtrl.text.trim() : m.firstName;
                    final newLast = lastCtrl.text.trim().isNotEmpty ? lastCtrl.text.trim() : m.lastName;

                    setS(() {
                      loading = true;
                      error = null;
                    });

                    final err = await _controller.updateName(
                      newFirstName: newFirst,
                      newLastName: newLast,
                    );

                    if (err != null) {
                      setS(() {
                        loading = false;
                        error = err;
                      });
                    } else {
                      Navigator.pop(ctx);
                      setState(() {});
                      _showSuccess(lang.t('Profil mis à jour !', 'Profile updated!'));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditPasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool loading = false;
    String? error;
    bool showOld = false;
    bool showNew = false;
    bool showConf = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final lang = ctx.watch<LanguageService>();
          return _buildDialog(
            title: lang.t('Modifier le mot de passe', 'Change Password'),
            icon: Icons.lock_outline,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  ctrl: oldCtrl,
                  hint: '••••••••',
                  label: lang.t('Ancien mot de passe', 'Current Password'),
                  icon: Icons.lock_outline,
                  obscure: !showOld,
                  suffix: IconButton(
                    icon: Icon(showOld ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                    onPressed: () => setS(() => showOld = !showOld),
                  ),
                ),
                const SizedBox(height: 16),
                _dialogField(
                  ctrl: newCtrl,
                  hint: '••••••••',
                  label: lang.t('Nouveau mot de passe', 'New Password'),
                  icon: Icons.lock_reset_outlined,
                  obscure: !showNew,
                  suffix: IconButton(
                    icon: Icon(showNew ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                    onPressed: () => setS(() => showNew = !showNew),
                  ),
                ),
                const SizedBox(height: 16),
                _dialogField(
                  ctrl: confirmCtrl,
                  hint: '••••••••',
                  label: lang.t('Confirmer le mot de passe', 'Confirm Password'),
                  icon: Icons.lock_reset_outlined,
                  obscure: !showConf,
                  suffix: IconButton(
                    icon: Icon(showConf ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                    onPressed: () => setS(() => showConf = !showConf),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  _errorText(error!),
                ],
                const SizedBox(height: 24),
                _dialogActions(
                  ctx: ctx,
                  loading: loading,
                  confirmLabel: lang.t('Modifier', 'Change'),
                  onConfirm: () async {
                    if (oldCtrl.text.isEmpty || newCtrl.text.isEmpty) {
                      setS(() => error = lang.t('Veuillez remplir tous les champs', 'Please fill all fields'));
                      return;
                    }
                    if (newCtrl.text != confirmCtrl.text) {
                      setS(() => error = lang.t('Les mots de passe ne correspondent pas', 'Passwords do not match'));
                      return;
                    }
                    if (newCtrl.text.length < 6) {
                      setS(() => error = lang.t('Minimum 6 caractères', 'Minimum 6 characters'));
                      return;
                    }

                    setS(() {
                      loading = true;
                      error = null;
                    });

                    final err = await _controller.updatePassword(
                      oldPassword: oldCtrl.text,
                      newPassword: newCtrl.text,
                    );

                    if (err != null) {
                      setS(() {
                        loading = false;
                        error = err;
                      });
                    } else {
                      Navigator.pop(ctx);
                      _showSuccess(lang.t('Mot de passe modifié !', 'Password changed!'));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditEmailDialog() {
    final m = _controller.model;
    final emailCtrl = TextEditingController();
    bool loading = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final lang = ctx.watch<LanguageService>();
          return _buildDialog(
            title: lang.t('Modifier l\'email', 'Change Email'),
            icon: Icons.email_outlined,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('Email actuel', 'Current email'),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(m.email, style: const TextStyle(color: Colors.white38, fontSize: 14)),
                ),
                const SizedBox(height: 16),
                _dialogField(
                  ctrl: emailCtrl,
                  hint: lang.t('Nouvel email', 'New email'),
                  label: lang.t('Nouvel email', 'New Email'),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        lang.t(
                          'Un code de vérification sera envoyé au nouvel email.',
                          'A verification code will be sent to the new email.',
                        ),
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  _errorText(error!),
                ],
                const SizedBox(height: 24),
                _dialogActions(
                  ctx: ctx,
                  loading: loading,
                  confirmLabel: lang.t('Envoyer le code', 'Send Code'),
                  onConfirm: () async {
                    final newEmail = emailCtrl.text.trim();
                    if (newEmail.isEmpty || !newEmail.contains('@')) {
                      setS(() => error = lang.t('Email invalide', 'Invalid email'));
                      return;
                    }
                    setS(() {
                      loading = true;
                      error = null;
                    });
                    final err = await _controller.requestEmailChange(newEmail: newEmail);
                    if (err != null) {
                      setS(() {
                        loading = false;
                        error = err;
                      });
                    } else {
                      Navigator.pop(ctx);
                      _showOtpEmailDialog(newEmail: newEmail);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOtpEmailDialog({required String newEmail}) {
    final otpCtrl = TextEditingController();
    bool loading = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final lang = ctx.watch<LanguageService>();
          return _buildDialog(
            title: lang.t('Vérification', 'Verification'),
            icon: Icons.verified_outlined,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang.t(
                    'Entrez le code envoyé à\n$newEmail',
                    'Enter the code sent to\n$newEmail',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                _dialogField(
                  ctrl: otpCtrl,
                  hint: '000000',
                  label: lang.t('Code de vérification', 'Verification Code'),
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  _errorText(error!),
                ],
                const SizedBox(height: 24),
                _dialogActions(
                  ctx: ctx,
                  loading: loading,
                  confirmLabel: lang.t('Confirmer', 'Confirm'),
                  onConfirm: () async {
                    if (otpCtrl.text.trim().isEmpty) {
                      setS(() => error = lang.t('Entrez le code', 'Enter the code'));
                      return;
                    }
                    setS(() {
                      loading = true;
                      error = null;
                    });
                    final err = await _controller.confirmEmailChange(
                      newEmail: newEmail,
                      otp: otpCtrl.text.trim(),
                    );
                    if (err != null) {
                      setS(() {
                        loading = false;
                        error = err;
                      });
                    } else {
                      Navigator.pop(ctx);
                      setState(() {});
                      _showSuccess(lang.t('Email mis à jour !', 'Email updated!'));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditChoiceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final lang = ctx.watch<LanguageService>();
          final h = MediaQuery.of(context).size.height;
          return _buildDialog(
            title: lang.t('Modifier le profil', 'Edit Profile'),
            icon: Icons.edit_outlined,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang.t('Que souhaitez-vous modifier ?', 'What would you like to edit?'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                _choiceButton(
                  h: h,
                  icon: Icons.person_outline,
                  label: lang.t('Prénom & Nom', 'First & Last Name'),
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditNameDialog();
                  },
                ),
                const SizedBox(height: 12),
                _choiceButton(
                  h: h,
                  icon: Icons.email_outlined,
                  label: lang.t('Adresse email', 'Email Address'),
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditEmailDialog();
                  },
                ),
                const SizedBox(height: 12),
                _choiceButton(
                  h: h,
                  icon: Icons.lock_outline,
                  label: lang.t('Mot de passe', 'Password'),
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditPasswordDialog();
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    lang.t('Annuler', 'Cancel'),
                    style: const TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════
  // HELPERS DIALOG
  // ══════════════════════════════════════════

  Widget _buildDialog({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B3E).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController ctrl,
    required String hint,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.white38, size: 18),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dialogActions({
    required BuildContext ctx,
    required bool loading,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: loading ? null : () => Navigator.pop(ctx),
            child: Text(
              _controller.t('Annuler', 'Cancel'), // ici on peut laisser ou remplacer par lang si besoin
              style: const TextStyle(color: Colors.white38),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: loading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(confirmLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _errorText(String msg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.red, fontSize: 13))),
          ],
        ),
      );

  Widget _choiceButton({
    required double h,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.chevron_right, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ══════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════

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
            opacity: 0.90,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : Row(
                  children: [
                    _buildSidebar(lang, h, w),
                    Expanded(child: _buildMainContent(lang, h, w)),
                    _buildRightPanel(lang, h, w),
                  ],
                ),
        ],
      ),
    );
  }

  // SIDEBAR
  Widget _buildSidebar(LanguageService lang, double h, double w) {
    final items = [
      {"icon": Icons.menu_book, "label": lang.t("Cours", "Courses")},
      {"icon": Icons.quiz, "label": lang.t("Quiz", "Quiz")},
      {"icon": Icons.emoji_events, "label": lang.t("Classement", "Leaderboard")},
      {"icon": Icons.folder, "label": lang.t("Fichiers", "Files")},
    ];

    return Container(
      width: w * 0.07,
      color: const Color.fromARGB(66, 33, 32, 32),
      child: Column(
        children: [
          SizedBox(height: h * 0.02),
          Image.asset("assets/images/icone_dash.png", width: h * 0.15, height: h * 0.15),
          SizedBox(height: h * 0.04),
          ...items.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () {
                if (entry.key == 0) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
                } else if (entry.key == 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuizSelectionPage()));
                } else if (entry.key == 2) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LeaderboardPage()));
                } else if (entry.key == 3) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FilesPage()));
                }
              },
              child: _buildSidebarItem(
                icon: entry.value["icon"] as IconData,
                label: entry.value["label"] as String,
                h: h,
                isActive: false,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: _buildSidebarItem(
              icon: Icons.logout,
              label: lang.t("Déconnexion", "Logout"),
              h: h,
              isLogout: true,
            ),
          ),
          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required double h,
    bool isLogout = false,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: h * 0.08,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
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
                  color: isActive ? Colors.blue : (isLogout ? Colors.red : Colors.white70),
                  size: h * 0.06,
                ),
                SizedBox(height: h * 0.005),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.blue : (isLogout ? Colors.red : Colors.white70),
                    fontSize: h * 0.018,
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

  // ══════════════════════════════════════════
  // CONTENU PRINCIPAL
  // ══════════════════════════════════════════

  Widget _buildMainContent(LanguageService lang, double h, double w) {
    final m = _controller.model;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          margin: EdgeInsets.all(h * 0.02),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(h * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileBanner(lang, h, w, m),
                SizedBox(height: h * 0.04),
                _buildSectionTitle("📋 ${lang.t('Informations personnelles', 'Personal Information')}", h),
                SizedBox(height: h * 0.02),
                _buildInfoFields(lang, h, w, m),
                SizedBox(height: h * 0.05),
                Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.blue.withValues(alpha: 0.5), Colors.transparent]))),
                SizedBox(height: h * 0.05),
                _buildSectionTitle("⚙️ ${lang.t('Paramètres', 'Settings')}", h),
                SizedBox(height: h * 0.008),
                Text(
                  lang.t("Personnalisez votre expérience et gérez votre compte.", "Customize your experience and manage your account."),
                  style: TextStyle(color: const Color.fromARGB(200, 255, 255, 255), fontSize: h * 0.018),
                ),
                SizedBox(height: h * 0.03),
                _buildSettingsSection(lang, h, w),
                SizedBox(height: h * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBanner(LanguageService lang, double h, double w, dynamic m) {
    return Container(
      padding: EdgeInsets.all(h * 0.025),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.withValues(alpha: 0.2), Colors.purple.withValues(alpha: 0.1)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: h * 0.11, height: h * 0.11, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue, width: 2.5))),
              CircleAvatar(
                radius: h * 0.045,
                backgroundColor: Colors.blue.withValues(alpha: 0.5),
                child: Text(m.firstName[0], style: TextStyle(color: Colors.white, fontSize: h * 0.04, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(width: w * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${m.firstName} ${m.lastName}", style: TextStyle(color: Colors.white, fontSize: h * 0.030, fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.005),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withValues(alpha: 0.4))),
                  child: Text(m.role.toUpperCase(), style: TextStyle(color: Colors.blue, fontSize: h * 0.013, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                ),
                SizedBox(height: h * 0.008),
                Text("ID : ${m.studentId}", style: TextStyle(color: Colors.white54, fontSize: h * 0.015)),
                SizedBox(height: h * 0.012),
                Row(
                  children: [
                    Text(lang.t("Progression globale", "Global Progress"), style: TextStyle(color: Colors.white54, fontSize: h * 0.014)),
                    SizedBox(width: w * 0.01),
                    Text("${(m.globalProgress * 100).toInt()}%", style: TextStyle(color: Colors.blue, fontSize: h * 0.014, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: h * 0.006),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: m.globalProgress,
                    minHeight: h * 0.009,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.02),
          GestureDetector(
            onTap: _showEditChoiceDialog,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: w * 0.015, vertical: h * 0.012),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)]),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    lang.t("Modifier le profil", "Edit Profile"),
                    style: TextStyle(color: Colors.white, fontSize: h * 0.015, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double h) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: h * 0.022, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: Colors.blue.withValues(alpha: 0.3))),
      ],
    );
  }

  Widget _buildInfoFields(LanguageService lang, double h, double w, dynamic m) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildField(lang.t("PRÉNOM", "FIRST NAME"), m.firstName, h, icon: Icons.person_outline)),
            SizedBox(width: w * 0.02),
            Expanded(child: _buildField(lang.t("NOM", "LAST NAME"), m.lastName, h, icon: Icons.person_outline)),
          ],
        ),
        SizedBox(height: h * 0.02),
        _buildField(lang.t("ADRESSE EMAIL", "EMAIL ADDRESS"), m.email, h, icon: Icons.email_outlined),
        SizedBox(height: h * 0.02),
        Row(
          children: [
            Expanded(child: _buildField(lang.t("NUMÉRO D'INSCRIPTION", "REGISTRATION NUMBER"), m.studentId, h, icon: Icons.badge_outlined)),
            SizedBox(width: w * 0.02),
            Expanded(child: _buildField(lang.t("DATE D'INSCRIPTION", "ENROLLMENT DATE"), m.enrollmentDate, h, icon: Icons.calendar_today_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, String value, double h, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white38, size: h * 0.018),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: const Color.fromARGB(200, 255, 255, 255), fontSize: h * 0.015)),
          ],
        ),
        SizedBox(height: h * 0.006),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: h * 0.015, vertical: h * 0.014),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(value, style: TextStyle(color: Colors.white70, fontSize: h * 0.016)),
        ),
      ],
    );
  }

  // SETTINGS SECTION
  Widget _buildSettingsSection(LanguageService lang, double h, double w) {
    final m = _controller.model;

    return Column(
      children: [
        _buildSettingsTile(
          h: h,
          icon: Icons.language,
          iconColor: Colors.blue,
          title: lang.t('Langue', 'Language'),
          subtitle: lang.isFrench ? "Français" : "English",
          trailing: GestureDetector(
            onTap: () {
              context.read<LanguageService>().toggleLanguage();
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: w * 0.012, vertical: h * 0.010),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: lang.isFrench
                      ? [Colors.blue.withValues(alpha: 0.6), Colors.blue.withValues(alpha: 0.3)]
                      : [Colors.purple.withValues(alpha: 0.6), Colors.purple.withValues(alpha: 0.3)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: lang.isFrench ? Colors.blue.withValues(alpha: 0.5) : Colors.purple.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang.isFrench ? "🇫🇷" : "🇬🇧", style: TextStyle(fontSize: h * 0.022)),
                  const SizedBox(width: 8),
                  Text(
                    lang.isFrench ? lang.t('Passer en anglais', 'Switch to English') : lang.t('Passer en français', 'Switch to French'),
                    style: TextStyle(color: Colors.white, fontSize: h * 0.015, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: h * 0.02),
        _buildSettingsTile(
          h: h,
          icon: m.soundEffects ? Icons.volume_up : Icons.volume_off,
          iconColor: m.soundEffects ? const Color(0xFF00E5FF) : Colors.white38,
          title: lang.t('Effets sonores', 'Sound Effects'),
          subtitle: m.soundEffects ? lang.t('Activés', 'Enabled') : lang.t('Désactivés', 'Disabled'),
          trailing: GestureDetector(
            onTap: () => setState(() => _controller.toggleSound()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: w * 0.06,
              height: h * 0.035,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: m.soundEffects ? const Color(0xFF00E5FF).withValues(alpha: 0.3) : Colors.white12,
                border: Border.all(color: m.soundEffects ? const Color(0xFF00E5FF) : Colors.white24, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: m.soundEffects ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: h * 0.028,
                      height: h * 0.028,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: m.soundEffects ? const Color(0xFF00E5FF) : Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required double h,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: h * 0.025, vertical: h * 0.02),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: h * 0.055,
            height: h * 0.055,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: iconColor, size: h * 0.030),
          ),
          SizedBox(width: h * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: h * 0.018, fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.004),
                Text(subtitle, style: TextStyle(color: Colors.white38, fontSize: h * 0.014)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // RIGHT PANEL
  Widget _buildRightPanel(LanguageService lang, double h, double w) {
    final m = _controller.model;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: w * 0.22,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            border: Border(left: BorderSide(color: Colors.blue.withValues(alpha: 0.2))),
          ),
          padding: EdgeInsets.all(h * 0.025),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(h * 0.02),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.withValues(alpha: 0.2), Colors.purple.withValues(alpha: 0.1)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: h * 0.03,
                      backgroundColor: Colors.blue.withValues(alpha: 0.5),
                      child: Text(m.firstName[0], style: TextStyle(color: Colors.white, fontSize: h * 0.022, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${m.firstName} ${m.lastName}", style: TextStyle(color: Colors.white, fontSize: h * 0.016, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          Text(m.role, style: TextStyle(color: Colors.white54, fontSize: h * 0.014)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.03),
              Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.blue, size: h * 0.022),
                  const SizedBox(width: 6),
                  Text(lang.t("Statistiques", "Statistics"), style: TextStyle(color: Colors.white, fontSize: h * 0.020, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: h * 0.02),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: h * 0.012,
                mainAxisSpacing: h * 0.012,
                childAspectRatio: 1.3,
                children: [
                  _buildStatBox(h, m.coursesSuivis.toString(), lang.t("Cours suivis", "Courses"), Colors.blue),
                  _buildStatBox(h, m.quizReussis.toString(), lang.t("Quiz réussis", "Quizzes"), const Color(0xFF00E5FF)),
                  _buildStatBox(h, "#${m.classement}", lang.t("Classement", "Ranking"), const Color(0xFFFFD700)),
                  _buildStatBox(h, m.pointsXP.toString(), "Points XP", Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(double h, String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: h * 0.028, fontWeight: FontWeight.bold)),
          SizedBox(height: h * 0.005),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: h * 0.013)),
        ],
      ),
    );
  }
}
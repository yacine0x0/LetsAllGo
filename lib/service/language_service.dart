// lib/service/language_service.dart
import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  bool isFrench = true;

  // ── Toggle + notifier toute l'app
  void toggleLanguage() {
    isFrench = !isFrench;
    notifyListeners();
  }

  void setFrench()  { isFrench = true;  notifyListeners(); }
  void setEnglish() { isFrench = false; notifyListeners(); }

  // ── Méthode principale — déclarer FR et EN directement
  String t(String fr, String en) => isFrench ? fr : en;
}
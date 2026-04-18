// lib/service/language_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class LanguageService extends ChangeNotifier {
  // ── Singleton
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  bool isFrench = true;
  Map<String, Map<String, String>> _translations = {};

  // ── Charger le fichier XML
  Future<void> loadTranslations() async {
    try {
      final xmlString = await rootBundle
          .loadString('assets/lang/translations.xml');
      final document = XmlDocument.parse(xmlString);

      _translations.clear();

      for (var element in document.findAllElements('string')) {
        final name = element.getAttribute('name') ?? '';
        final fr   = element.getAttribute('fr')   ?? '';
        final en   = element.getAttribute('en')   ?? '';
        _translations[name] = {'fr': fr, 'en': en};
      }
      print('✅ Traductions chargées: ${_translations.length} clés');
    } catch (e) {
      print('❌ Erreur chargement traductions: $e');
    }
  }

  // ── Traduire une clé
  String t(String key, {String fallback = ''}) {
    final map = _translations[key];
    if (map == null) return fallback.isNotEmpty ? fallback : key;
    return isFrench ? (map['fr'] ?? fallback) : (map['en'] ?? fallback);
  }

  // ── Toggle langue + notifier toute l'app
  void toggleLanguage() {
    isFrench = !isFrench;
    notifyListeners(); // ✅ rebuild toutes les pages
  }

  void setFrench()  { isFrench = true;  notifyListeners(); }
  void setEnglish() { isFrench = false; notifyListeners(); }
}
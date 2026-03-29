import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import '../models/courses_study/courses_study_model.dart';

class XmlService {

  // Charge un fichier XML et retourne la liste des sections
  static Future<List<section>> loadChapterSections(String xmlPath) async {
    // 1. Lire le fichier XML depuis assets
    final xmlString = await rootBundle.loadString(xmlPath);

    // 2. Parser le XML
    final document = XmlDocument.parse(xmlString);

    // 3. Extraire les sections
    final sections = <section>[];

    for (final sectionElement in document.findAllElements('section')) {
      final id = sectionElement.getAttribute('id') ?? '';
      final title = sectionElement.getAttribute('title') ?? '';
      final content = sectionElement.findElements('content').first.innerText.trim();

      // Image optionnelle
      String? imagePath;
      final imageElements = sectionElement.findElements('imagePath');
      if (imageElements.isNotEmpty) {
        imagePath = imageElements.first.innerText.trim();
      }

      // Bullet points optionnels
      List<String>? bulletPoints;
      final bulletPointElements = sectionElement.findAllElements('point');
      if (bulletPointElements.isNotEmpty) {
        bulletPoints = bulletPointElements
            .map((e) => e.innerText.trim())
            .toList();
      }

      sections.add(section(
        id: id,
        title: title,
        content: content,
        imagePath: imagePath,
        bulletPoints: bulletPoints,
      ));
    }

    return sections;
  }

  // Retourne les titres des sections comme liste de leçons
  static Future<List<String>> getLessonsFromXml(String xmlPath) async {
    final sections = await loadChapterSections(xmlPath);
    return sections.map((s) => s.title).toList(); // ← titre de chaque section = leçon
  }

  // Chemin XML selon le chapitre
  static String getXmlPath(String algo, String chapterId) {
    // ex: algo1, "Chapitre 01" → assets/courses/algo1/chapter01_basics.xml
    final chapterNumber = chapterId.replaceAll('Chapitre ', '').padLeft(2, '0');
    return 'assets/courses/$algo/chapter${chapterNumber}.xml';
  }
}
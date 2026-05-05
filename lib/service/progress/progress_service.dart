// lib/service/progress/progress_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../auth/LoginService.dart';

class ProgressService {
  // ── URL selon la plateforme
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  static const int _algo1TotalChapters = 5;
  static const int _algo2TotalChapters = 4;

  // ── Cache local synchronisé avec la DB
  static double _algo1Progress  = 0.0;
  static double _algo2Progress  = 0.0;
  static double _globalProgress = 0.0;
  static final Set<String> _completedChapters = {};
  static final Set<String> _completedChapterIds = {};

  // ── Enregistrer visite
  static Future<void> recordVisit({
    required String algoType,
    required String chapterTitle,
  }) async {
    final token = LoginService.getToken();
    if (token == null) {
      print('❌ recordVisit: token manquant');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/courses/visit'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chapterTitle': chapterTitle,
          'algoType':     algoType,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (data['isCompleted'] == true) {
          _completedChapters.add('${algoType}_$chapterTitle');
        }
        print('✅ Visite enregistrée: $chapterTitle');
      } else {
        print('❌ recordVisit: ${data['message']}');
      }
    } catch (e) {
      print('❌ recordVisit error: $e');
    }
  }

  // ── Marquer un chapitre comme complété
  static Future<bool> completeChapter({
    required String algoType,
    required String chapterTitle,
  }) async {
    final token = LoginService.getToken();
    if (token == null) {
      print('❌ completeChapter: token manquant');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/courses/complete'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chapterTitle': chapterTitle,
          'algoType':     algoType,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _completedChapters.add('${algoType}_$chapterTitle');

        final progress = data['progress'];
        if (progress != null) {
          _algo1Progress  = (progress['algo1']['progress'] as num).toDouble();
          _algo2Progress  = (progress['algo2']['progress'] as num).toDouble();
          _globalProgress = (progress['global']['progress'] as num).toDouble();
        }

        print('✅ Chapitre complété: $chapterTitle');
        print('📊 algo1=${(_algo1Progress * 100).toInt()}% algo2=${(_algo2Progress * 100).toInt()}% global=${(_globalProgress * 100).toInt()}%');
        return true;
      }

      print('❌ completeChapter: ${data['message']}');
      return false;
    } catch (e) {
      print('❌ completeChapter error: $e');
      return false;
    }
  }

  // ── Charger progression depuis DB
  static Future<void> loadProgress() async {
    final token = LoginService.getToken();
    if (token == null) {
      print('❌ loadProgress: token manquant');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/courses/progress'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _algo1Progress  = (data['algo1']['progress'] as num).toDouble();
        _algo2Progress  = (data['algo2']['progress'] as num).toDouble();
        _globalProgress = (data['global']['progress'] as num).toDouble();

        _completedChapters.clear();
        _completedChapterIds.clear();
        final completed = data['completedChapters'] as List<dynamic>? ?? [];
        for (final c in completed) {
          _completedChapters.add(c as String);
        }
        final completedIds = data['completedChapterIds'] as List<dynamic>? ?? [];
        for (final c in completedIds) {
          _completedChapterIds.add(c as String);
        }

        print('✅ Progression chargée:');
        print('   algo1  = ${(_algo1Progress  * 100).toInt()}%');
        print('   algo2  = ${(_algo2Progress  * 100).toInt()}%');
        print('   global = ${(_globalProgress * 100).toInt()}%');
        print('   complétés: $_completedChapters');
      } else {
        print('❌ loadProgress: ${data['message']}');
      }
    } catch (e) {
      print('❌ loadProgress error: $e');
    }
  }

  // ── Réinitialiser au logout
  static void reset() {
    _algo1Progress  = 0.0;
    _algo2Progress  = 0.0;
    _globalProgress = 0.0;
    _completedChapters.clear();
    _completedChapterIds.clear();
    print('✅ Progression réinitialisée');
  }

  // ── Getters
  static double getAlgo1Progress()  => _algo1Progress;
  static double getAlgo2Progress()  => _algo2Progress;
  static double getGlobalProgress() => _globalProgress;

  static bool isAlreadyCompleted(String algoType, String chapterTitle) =>
      _completedChapters.contains('${algoType}_$chapterTitle');

  static bool isChapterCompletedById(String algoType, String chapterId) =>
      _completedChapterIds.contains('${algoType}_$chapterId');
}
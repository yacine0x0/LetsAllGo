import 'package:flutter/foundation.dart';

/// Simple logger: imprime uniquement en debug.
class AppLogger {
  static void d(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static void e(String message, {Object? error}) {
    if (kDebugMode) {
      debugPrint(error == null ? message : '$message\n$error');
    }
  }
}


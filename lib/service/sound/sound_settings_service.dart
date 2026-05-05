import 'package:shared_preferences/shared_preferences.dart';

class SoundSettingsService {
  static const String soundEffectsKey = 'profile_sound_effects';

  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(soundEffectsKey) ?? true;
  }
}

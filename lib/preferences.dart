import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyper_net/application.dart';
import 'package:hyper_net/models/language.dart';

class Preferences {
  static SharedPreferences? _sharedPreferences;

  static Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPreferences != null) {
      return _sharedPreferences!;
    } else {
      _sharedPreferences = await SharedPreferences.getInstance();
      return _sharedPreferences!;
    }
  }

  static const String _languageKey = 'LanguageId';
  static const String _appearanceKey = 'Appearance';

  static Language? _applicationLanguage;
  static int? _appearance;

  static Future<void> loadSettings() async {
    final preferences = await sharedPreferences;

    int? languageId = preferences.getInt(_languageKey);
    if (languageId == null) {
      languageId = 0;
      preferences.setInt(_languageKey, languageId);
    } else if (languageId > languages.length - 1) {
      languageId = 0;
      preferences.setInt(_languageKey, languageId);
    }

    _applicationLanguage = languages[languageId];

    _appearance = preferences.getInt(_appearanceKey) ?? 0;
  }

  static Future<Language> applicationLanguage() async {
    if (_applicationLanguage == null) {
      final preferences = await sharedPreferences;

      int? languageId = preferences.getInt(_languageKey);

      if (languageId == null) {
        languageId = 0;
        preferences.setInt(_languageKey, languageId);
      } else if (languageId > languages.length - 1) {
        languageId = 0;
        preferences.setInt(_languageKey, languageId);
      }

      _applicationLanguage = languages[languageId];

      return _applicationLanguage!;
    } else {
      return _applicationLanguage!;
    }
  }

  static Future<void> setApplicationLanguage(int languageId) async {
    if (languageId <= languages.length - 1) {
      final sharedPreferences = await SharedPreferences.getInstance();

      _applicationLanguage = languages[languageId];

      sharedPreferences.setInt(_languageKey, languageId);
    }
  }

  static Future<int> appearance() async {
    if (_appearance != null) {
      return _appearance!;
    } else {
      final sharedPreferences = await SharedPreferences.getInstance();
      _appearance = sharedPreferences.getInt(_appearanceKey) ?? 0;

      return _appearance!;
    }
  }

  static Future<void> setAppearance(int appearance) async {
    _appearance = appearance;

    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_appearanceKey, appearance);
  }
}

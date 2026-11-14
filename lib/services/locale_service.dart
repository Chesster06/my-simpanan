import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_translations_data.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

class LocaleService extends ChangeNotifier {
  static const String keyLanguageCode = 'pref_language_code';
  static const String keyLanguageName = 'pref_language_name';

  static final LocaleService instance = LocaleService._internal();
  LocaleService._internal();

  // Exactly 4 supported languages in Malaysia / Singapore region:
  // English (default), Malay, Chinese, Tamil
  static const List<LanguageOption> allLanguages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu'),
    LanguageOption(code: 'zh', name: 'Chinese', nativeName: '中文 (Simplified)'),
    LanguageOption(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
  ];

  // Fixed Currency: RM (MYR) - non-changeable
  static const String defaultCurrencySymbol = 'RM';
  static const String defaultCurrencyCode = 'MYR';

  String get currencySymbol => defaultCurrencySymbol;
  String get currencyCode => defaultCurrencyCode;

  LanguageOption _selectedLanguage = allLanguages[0]; // English default
  bool _isInitialized = false;

  LanguageOption get currentLanguage => _selectedLanguage;
  String get languageName => _selectedLanguage.name;
  String get langCode => _selectedLanguage.code;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();

    final savedLang = prefs.getString(keyLanguageCode) ?? 'en';
    _selectedLanguage = allLanguages.firstWhere(
      (l) => l.code.toLowerCase() == savedLang.toLowerCase(),
      orElse: () => allLanguages[0],
    );

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(LanguageOption language) async {
    _selectedLanguage = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguageCode, language.code);
    await prefs.setString(keyLanguageName, language.name);
  }

  String formatCurrency(num amount) {
    final formattedNum = amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return 'RM $formattedNum';
  }

  /// Translate a key into currently selected language with English fallback
  String tr(String key, {Map<String, String>? params}) {
    final code = _selectedLanguage.code;
    return AppTranslations.get(code, key, params: params);
  }
}

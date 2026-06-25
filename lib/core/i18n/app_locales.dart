import 'package:flutter/widgets.dart';

/// One selectable UI language. `nativeName` is the autonym (the language's name
/// written in its own script) so the picker reads naturally to a speaker of
/// that language; `englishName` is shown as a secondary, always-legible label.
@immutable
class AppLanguage {
  const AppLanguage({
    required this.locale,
    required this.englishName,
    required this.nativeName,
    this.isRtl = false,
  });

  final Locale locale;
  final String englishName;
  final String nativeName;

  /// True for right-to-left scripts (Arabic, Urdu). Flutter resolves text
  /// direction from the active locale on its own; this flag is for our own UI
  /// (e.g. previewing direction in the picker), not for driving [Directionality].
  final bool isRtl;

  /// The BCP-47-ish tag persisted in preferences (e.g. `en`, `zh`, `pt_BR`).
  String get code => locale.countryCode == null
      ? locale.languageCode
      : '${locale.languageCode}_${locale.countryCode}';
}

/// The languages the app ships translations for. Order is the picker order:
/// English first, then by global speaker count. Keep this list in sync with the
/// `app_<code>.arb` files in `lib/l10n/`.
const List<AppLanguage> kSupportedLanguages = [
  AppLanguage(locale: Locale('en'), englishName: 'English', nativeName: 'English'),
  AppLanguage(locale: Locale('zh'), englishName: 'Chinese (Simplified)', nativeName: '中文（简体）'),
  AppLanguage(locale: Locale('hi'), englishName: 'Hindi', nativeName: 'हिन्दी'),
  AppLanguage(locale: Locale('es'), englishName: 'Spanish', nativeName: 'Español'),
  AppLanguage(locale: Locale('ar'), englishName: 'Arabic', nativeName: 'العربية', isRtl: true),
  AppLanguage(locale: Locale('fr'), englishName: 'French', nativeName: 'Français'),
  AppLanguage(locale: Locale('bn'), englishName: 'Bengali', nativeName: 'বাংলা'),
  AppLanguage(locale: Locale('pt'), englishName: 'Portuguese', nativeName: 'Português'),
  AppLanguage(locale: Locale('ru'), englishName: 'Russian', nativeName: 'Русский'),
  AppLanguage(locale: Locale('ur'), englishName: 'Urdu', nativeName: 'اردو', isRtl: true),
];

/// The [Locale]s handed to `MaterialApp.supportedLocales`.
List<Locale> get kSupportedLocales =>
    kSupportedLanguages.map((l) => l.locale).toList(growable: false);

/// Parse a persisted code (`en`, `pt_BR`) back into a [Locale], or null when the
/// string is null/empty/unknown — in which case the app follows the system.
Locale? localeFromCode(String? code) {
  if (code == null || code.isEmpty) return null;
  final parts = code.split('_');
  final candidate =
      parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  for (final lang in kSupportedLanguages) {
    if (lang.locale.languageCode == candidate.languageCode &&
        lang.locale.countryCode == candidate.countryCode) {
      return lang.locale;
    }
  }
  // Fall back to a language-only match (e.g. persisted `en_US` -> supported `en`).
  for (final lang in kSupportedLanguages) {
    if (lang.locale.languageCode == candidate.languageCode) return lang.locale;
  }
  return null;
}

/// Look up the [AppLanguage] for a resolved locale, defaulting to English.
AppLanguage languageForLocale(Locale? locale) {
  if (locale != null) {
    for (final lang in kSupportedLanguages) {
      if (lang.locale.languageCode == locale.languageCode) return lang;
    }
  }
  return kSupportedLanguages.first;
}

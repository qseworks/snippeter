import 'package:flutter/material.dart';

/// User preferences, persisted via SharedPreferences.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.exportTheme = 'atom-one-dark',
    this.exportWatermark = true,
    this.defaultLanguageId,
    this.localeCode,
  });

  final ThemeMode themeMode;
  final String exportTheme;
  final bool exportWatermark;
  final String? defaultLanguageId;

  /// Selected UI language as a code (`en`, `ar`, `pt_BR`). Null means "follow
  /// the system locale" — the picker's default. Distinct from
  /// [defaultLanguageId], which is the default *programming* language for new
  /// snippets, not the interface language.
  final String? localeCode;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? exportTheme,
    bool? exportWatermark,
    String? defaultLanguageId,
    bool clearDefaultLanguage = false,
    String? localeCode,
    bool clearLocale = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      exportTheme: exportTheme ?? this.exportTheme,
      exportWatermark: exportWatermark ?? this.exportWatermark,
      defaultLanguageId: clearDefaultLanguage
          ? null
          : (defaultLanguageId ?? this.defaultLanguageId),
      localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
    );
  }
}

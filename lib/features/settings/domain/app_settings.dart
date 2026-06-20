import 'package:flutter/material.dart';

/// User preferences, persisted via SharedPreferences.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.exportTheme = 'atom-one-dark',
    this.exportWatermark = true,
    this.defaultLanguageId,
  });

  final ThemeMode themeMode;
  final String exportTheme;
  final bool exportWatermark;
  final String? defaultLanguageId;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? exportTheme,
    bool? exportWatermark,
    String? defaultLanguageId,
    bool clearDefaultLanguage = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      exportTheme: exportTheme ?? this.exportTheme,
      exportWatermark: exportWatermark ?? this.exportWatermark,
      defaultLanguageId: clearDefaultLanguage
          ? null
          : (defaultLanguageId ?? this.defaultLanguageId),
    );
  }
}

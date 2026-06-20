import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

const _kThemeMode = 'themeMode';
const _kExportTheme = 'exportTheme';
const _kExportWatermark = 'exportWatermark';
const _kDefaultLanguage = 'defaultLanguageId';

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      themeMode: _parseThemeMode(prefs.getString(_kThemeMode)),
      exportTheme: prefs.getString(_kExportTheme) ?? 'atom-one-dark',
      exportWatermark: prefs.getBool(_kExportWatermark) ?? true,
      defaultLanguageId: prefs.getString(_kDefaultLanguage),
    );
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  void setThemeMode(ThemeMode mode) {
    _prefs.setString(_kThemeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  void setExportTheme(String theme) {
    _prefs.setString(_kExportTheme, theme);
    state = state.copyWith(exportTheme: theme);
  }

  void setExportWatermark({required bool value}) {
    _prefs.setBool(_kExportWatermark, value);
    state = state.copyWith(exportWatermark: value);
  }

  void setDefaultLanguage(String? languageId) {
    if (languageId == null) {
      _prefs.remove(_kDefaultLanguage);
      state = state.copyWith(clearDefaultLanguage: true);
    } else {
      _prefs.setString(_kDefaultLanguage, languageId);
      state = state.copyWith(defaultLanguageId: languageId);
    }
  }

  static ThemeMode _parseThemeMode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

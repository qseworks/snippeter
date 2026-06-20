import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/highlight/code_themes.dart';
import '../../../core/highlight/language_visuals.dart';
import '../../snippets/application/snippet_providers.dart';
import '../../snippets/domain/value_objects.dart';
import '../application/settings_providers.dart';

/// App settings: appearance, export defaults and editor defaults (persisted).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final languages = ref.watch(languagesProvider).value ?? const <Language>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionHeader('Appearance'),
              Card(
                child: ListTile(
                  title: const Text('Theme'),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.system, label: Text('System')),
                      ButtonSegment(
                          value: ThemeMode.light, label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => controller.setThemeMode(s.first),
                  ),
                ),
              ),
              const _SectionHeader('Export defaults'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Default image theme'),
                      trailing: DropdownButton<String>(
                        value: CodeThemes.exportThemeNames
                                .contains(settings.exportTheme)
                            ? settings.exportTheme
                            : CodeThemes.exportThemeNames.first,
                        items: [
                          for (final name in CodeThemes.exportThemeNames)
                            DropdownMenuItem(value: name, child: Text(name)),
                        ],
                        onChanged: (v) {
                          if (v != null) controller.setExportTheme(v);
                        },
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Show watermark on image exports'),
                      value: settings.exportWatermark,
                      onChanged: (v) =>
                          controller.setExportWatermark(value: v),
                    ),
                  ],
                ),
              ),
              const _SectionHeader('Editor defaults'),
              Card(
                child: ListTile(
                  title: const Text('Default language for new snippets'),
                  trailing: DropdownButton<String?>(
                    value: languages.any((l) => l.id == settings.defaultLanguageId)
                        ? settings.defaultLanguageId
                        : null,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final l in languages)
                        DropdownMenuItem(
                          value: l.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LanguageBadge(languageId: l.id, size: 18),
                              const SizedBox(width: 8),
                              Text(l.name),
                            ],
                          ),
                        ),
                    ],
                    onChanged: controller.setDefaultLanguage,
                  ),
                ),
              ),
              const _SectionHeader('About'),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.bookmarks_outlined),
                  title: Text('Snippet Manager'),
                  subtitle: Text('Local-first • sync-ready • all your platforms'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

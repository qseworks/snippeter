import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/settings_providers.dart';

/// Root application widget. Wires the router and themes; it deliberately knows
/// nothing about storage or features — those attach through Riverpod providers.
class SnippetManagerApp extends ConsumerWidget {
  const SnippetManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(settingsProvider).themeMode;
    return MaterialApp.router(
      title: 'Snippet Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

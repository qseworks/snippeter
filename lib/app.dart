import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/settings_providers.dart';
import 'features/snippets/application/snippet_providers.dart';
import 'features/snippets/presentation/snippet_editor_modal.dart';

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
      // Wrap every route in global keyboard shortcuts. The builder runs below
      // the Navigator/Overlay, so `showSnippetEditor` gets a valid context that
      // can host the modal dialog.
      builder: (context, child) => _GlobalShortcuts(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// App-wide keyboard shortcuts:
///   * Cmd/Ctrl+N — open the new-snippet editor modal.
///   * Cmd/Ctrl+F — focus the Library search field.
///   * Esc — handled by the open dialog itself (no-op here otherwise).
///
/// Uses [CallbackShortcuts] with both `meta` (macOS) and `control` (everywhere
/// else) activators so the shortcuts work across platforms.
class _GlobalShortcuts extends ConsumerWidget {
  const _GlobalShortcuts({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void newSnippet() => showSnippetEditor(context);
    void focusSearch() => ref.read(searchFocusProvider).requestFocus();

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): newSnippet,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            newSnippet,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): focusSearch,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            focusSearch,
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

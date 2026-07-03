import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/routing/route_paths.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'features/settings/application/settings_providers.dart';
import 'features/sync/application/sync_providers.dart';
import 'features/snippets/application/snippet_providers.dart';
import 'features/snippets/presentation/snippet_editor_modal.dart';

/// Root application widget. Wires the router and themes; it deliberately knows
/// nothing about storage or features — those attach through Riverpod providers.
class SnippetManagerApp extends ConsumerWidget {
  const SnippetManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    // select() so unrelated settings (export theme, default language…) don't
    // rebuild the entire MaterialApp.router.
    final themeMode =
        ref.watch(settingsProvider.select((s) => s.themeMode));
    // Selected UI language; null follows the system locale. Flutter resolves
    // text direction (RTL for Arabic/Urdu) from this locale via the global
    // localizations delegates below — no manual Directionality needed.
    final locale = ref.watch(localeProvider);
    // Start the auth -> sync lifecycle bridge (no-op when offline/signed out).
    ref.watch(syncBootstrapProvider);
    return MaterialApp.router(
      title: 'Snippeter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
///   * Cmd/Ctrl+, — open Settings (macOS Preferences convention).
///   * Esc — handled by the open dialog itself (no-op here otherwise).
///
/// Uses [CallbackShortcuts] with both `meta` (macOS) and `control` (everywhere
/// else) activators so the shortcuts work across platforms.
class _GlobalShortcuts extends ConsumerStatefulWidget {
  const _GlobalShortcuts({required this.child});

  final Widget child;

  @override
  ConsumerState<_GlobalShortcuts> createState() => _GlobalShortcutsState();
}

class _GlobalShortcutsState extends ConsumerState<_GlobalShortcuts> {
  // A root focus node so the global shortcuts below receive key events without
  // the user having to click into the app first.
  //
  // We request focus *after the first frame* instead of using `autofocus: true`.
  // On Flutter web, an autofocus at the app root acquires focus during the
  // first frame; the engine then round-trips a view-focus change back into
  // `FocusTraversalPolicy.findFirstFocus`, which sorts every focusable
  // descendant by its `rect`. Mid-first-frame, some descendants aren't laid out
  // yet, so reading `rect` throws the `RenderBox was not laid out` (`hasSize`)
  // assertion. Deferring to a post-frame callback guarantees the tree is laid
  // out before focus traversal runs.
  final FocusNode _rootFocusNode = FocusNode(debugLabel: 'GlobalShortcutsRoot');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _rootFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _rootFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void newSnippet() => showSnippetEditor(context);
    void focusSearch() => ref.read(searchFocusProvider).requestFocus();
    void openSettings() => ref.read(goRouterProvider).go(RoutePaths.settings);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): newSnippet,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            newSnippet,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): focusSearch,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            focusSearch,
        const SingleActivator(LogicalKeyboardKey.comma, meta: true):
            openSettings,
        const SingleActivator(LogicalKeyboardKey.comma, control: true):
            openSettings,
      },
      child: Focus(focusNode: _rootFocusNode, child: widget.child),
    );
  }
}

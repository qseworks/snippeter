import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_shell/app_shell.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/snippets/presentation/snippet_detail_screen.dart';
import '../../features/snippets/presentation/snippet_editor_screen.dart';
import '../../features/snippets/presentation/snippet_list_screen.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// The router is exposed as a provider so later features (e.g. auth redirect on
/// sync) can depend on app state without restructuring the widget tree.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.library,
    routes: [
      // The persistent Snippet 3-pane shell. Library + Settings render inside it;
      // "Starred"/"Unlabeled" etc. are sidebar filters on the library query.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.library,
            builder: (context, state) => const LibraryContent(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Top-level routes pushed over the shell (root navigator), so they never
      // replace the shell chrome.
      GoRoute(
        path: '/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SnippetEditorScreen(),
      ),
      GoRoute(
        path: '/snippet/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            SnippetDetailScreen(snippetId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) =>
                SnippetEditorScreen(snippetId: state.pathParameters['id']),
          ),
        ],
      ),
    ],
  );
});

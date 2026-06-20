import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../snippets/presentation/snippet_editor_modal.dart';
import 'library_sidebar.dart';

/// The Snippet-style master shell. Owns the [Scaffold] and lays out the dark
/// 3-pane chrome on wide screens: a thin workspace rail, the dark
/// [LibrarySidebar], and the routed content (`child`). On narrow screens the
/// sidebar collapses into a [Drawer] behind a hamburger app bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const double _wideBreakpoint = 760;
  static const double _railWidth = 52;
  static const double _sidebarWidth = 264;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            const _WorkspaceRail(width: _railWidth),
            const SizedBox(
              width: _sidebarWidth,
              child: LibrarySidebar(),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const Drawer(
        width: _sidebarWidth,
        child: LibrarySidebar(inDrawer: true),
      ),
      appBar: AppBar(title: const Text('Snippets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSnippetEditor(context),
        child: const Icon(Icons.add),
      ),
      body: child,
    );
  }
}

/// The far-left dark workspace rail: a brand mark on a gradient tile at the top
/// and a circular avatar placeholder at the bottom.
class _WorkspaceRail extends StatelessWidget {
  const _WorkspaceRail({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppTheme.sidebarRailBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 14),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient(Brightness.dark),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Text(
              '</>',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 15,
            backgroundColor: AppTheme.sidebarSelected,
            child: Icon(Icons.person, size: 18, color: AppTheme.sidebarMuted),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

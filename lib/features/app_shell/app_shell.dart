import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/snippeter_mark.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../snippets/presentation/snippet_editor_modal.dart';
import '../workspaces/application/workspace_providers.dart';
import '../workspaces/domain/workspace.dart';
import '../workspaces/presentation/create_workspace_dialog.dart';
import '../workspaces/presentation/team_screen.dart';
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
    final l10n = AppLocalizations.of(context);
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
        width: _railWidth + _sidebarWidth,
        child: Row(
          children: [
            _WorkspaceRail(width: _railWidth),
            Expanded(child: LibrarySidebar(inDrawer: true)),
          ],
        ),
      ),
      appBar: AppBar(title: Text(l10n.shellSnippetsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSnippetEditor(context),
        child: const Icon(Icons.add),
      ),
      body: child,
    );
  }
}

/// The far-left dark workspace rail: a brand mark at the top, then the library
/// switcher — a "Personal" button plus one circular avatar per team library
/// from [workspacesProvider]. The active library shows a green ring/bar (via
/// [AppTheme.brandGreen]); tapping switches [activeWorkspaceProvider]. When signed
/// in ([workspaceServiceProvider] != null) a "+" button at the bottom creates a
/// team; when signed out only Personal is shown.
class _WorkspaceRail extends ConsumerWidget {
  const _WorkspaceRail({required this.width});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeWorkspaceProvider);
    final teams = ref.watch(workspacesProvider).value ?? const <Workspace>[];
    final canCreate = ref.watch(workspaceServiceProvider) != null;

    return Container(
      width: width,
      color: AppTheme.sidebarRailBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 14),
          const SnippeterMark(size: 34),
          const SizedBox(height: 14),
          const _RailDivider(),
          // Scrollable library switcher: Personal + one avatar per team.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _WorkspaceTile(
                    label: l10n.shellWorkspacePersonal,
                    icon: Icons.person_outline,
                    selected: active == null,
                    onTap: () => ref
                        .read(activeWorkspaceProvider.notifier)
                        .setWorkspace(null),
                  ),
                  for (final ws in teams)
                    _WorkspaceTile(
                      label: ws.name,
                      initial: _initialOf(ws.name),
                      selected: active == ws.id,
                      onTap: () => ref
                          .read(activeWorkspaceProvider.notifier)
                          .setWorkspace(ws.id),
                      onManage: () => showTeamManagement(context, ws.id),
                    ),
                ],
              ),
            ),
          ),
          if (canCreate) ...[
            const _RailDivider(),
            const SizedBox(height: 8),
            _WorkspaceTile(
              label: l10n.shellCreateTeam,
              icon: Icons.add,
              selected: false,
              onTap: () => showCreateWorkspaceDialog(context),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  static String _initialOf(String name) {
    final t = name.trim();
    return t.isEmpty ? '?' : t.characters.first.toUpperCase();
  }
}

/// A hairline divider sized for the narrow rail.
class _RailDivider extends StatelessWidget {
  const _RailDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 1,
      color: AppTheme.sidebarSelected,
    );
  }
}

/// One circular entry in the workspace rail. Shows an [icon] (Personal / "+")
/// or an [initial] avatar (team). The active tile gets a green ring plus a small
/// green bar on the left edge. A team tile supports long-press / right-click and
/// a gear affordance to open management via [onManage].
class _WorkspaceTile extends StatelessWidget {
  const _WorkspaceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.initial,
    this.onManage,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? initial;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    const double size = 34;
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppTheme.sidebarSelected : AppTheme.sidebarHover,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppTheme.brandGreen : Colors.transparent,
          width: 2,
        ),
      ),
      child: icon != null
          ? Icon(
              icon,
              size: 18,
              color: selected ? AppTheme.sidebarText : AppTheme.sidebarMuted,
            )
          : Text(
              initial ?? '?',
              style: TextStyle(
                color: selected ? AppTheme.sidebarText : AppTheme.sidebarMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
    );

    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active bar on the very left edge of the rail.
            Container(
              width: 3,
              height: size,
              decoration: BoxDecoration(
                color: selected ? AppTheme.brandGreen : Colors.transparent,
                borderRadius: const BorderRadiusDirectional.horizontal(
                  end: Radius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onTap,
              onLongPress: onManage,
              onSecondaryTap: onManage,
              customBorder: const CircleBorder(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  avatar,
                  if (onManage != null)
                    // Offsets account for _GearBadge's transparent hit padding
                    // so the visible 16px gear stays pinned to the avatar's
                    // bottom-end corner while the tap target spans ~40px.
                    PositionedDirectional(
                      end: -16,
                      bottom: -16,
                      child: _GearBadge(onTap: onManage!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small gear affordance overlaid on a team avatar to open team management.
/// The badge stays a crisp 16px, but a transparent [_hitSize]px hit area keeps
/// it comfortably tappable.
class _GearBadge extends StatelessWidget {
  const _GearBadge({required this.onTap});

  final VoidCallback onTap;

  static const double _badgeSize = 16;
  static const double _hitSize = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: l10n.shellManageTeam,
      child: InkResponse(
        onTap: onTap,
        radius: _hitSize / 2,
        containedInkWell: false,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _hitSize,
          height: _hitSize,
          child: Center(
            child: Container(
              width: _badgeSize,
              height: _badgeSize,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppTheme.sidebarRailBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings,
                size: 11,
                color: AppTheme.sidebarMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../auth/application/auth_providers.dart';
import '../application/workspace_providers.dart';
import '../data/workspace_service.dart';
import '../domain/workspace.dart';

/// Opens the team-management surface for [workspaceId]: a large dialog on wide
/// layouts, a near-full-screen sheet on narrow ones. The rail calls this when a
/// team library's "Manage team" action is tapped.
///
/// Everything inside reads the LIVE local cache ([workspaceMembersProvider]) so
/// it reflects offline state, and gates editing on the signed-in user's role.
Future<void> showTeamManagement(BuildContext context, String workspaceId) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (context) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: TeamScreen(workspaceId: workspaceId),
      ),
    ),
  );
}

/// The team-management body: team name, members list (with role editing for
/// managers/owners), an invite row, and leave/delete actions. Usable on its own
/// as a routed screen too — it's a self-contained [Scaffold]-less column.
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = ref.watch(workspaceServiceProvider);

    // Find this workspace in the cached list to get its name + my role.
    final workspaces = ref.watch(workspacesProvider).value ?? const <Workspace>[];
    final workspace = workspaces
        .where((w) => w.id == workspaceId)
        .cast<Workspace?>()
        .firstWhere((_) => true, orElse: () => null);

    final membersAsync = ref.watch(workspaceMembersProvider(workspaceId));
    final currentUser = ref.watch(currentUserProvider);
    final myUserId = currentUser?.id;

    // My role: prefer the workspace row, fall back to my membership row.
    final members = membersAsync.value ?? const <WorkspaceMember>[];
    final myMember = myUserId == null
        ? null
        : members.where((m) => m.userId == myUserId).cast<WorkspaceMember?>()
            .firstWhere((_) => true, orElse: () => null);
    final myRole = workspace?.myRole ?? myMember?.role;
    final canManage = myRole?.canManage ?? false;

    final title = workspace?.name.isNotEmpty == true
        ? workspace!.name
        : l10n.teamFallbackTitle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Header ----------------------------------------------------------
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 12, 12),
          child: Row(
            children: [
              Icon(Icons.groups_outlined, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.teamSubtitleLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.commonClose,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // --- Body ------------------------------------------------------------
        Flexible(
          child: service == null
              ? const _OfflineNotice()
              : membersAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: _TeamError(message: friendlyWorkspaceError(context, e)),
                  ),
                  data: (members) => _TeamBody(
                    workspaceId: workspaceId,
                    service: service,
                    members: members,
                    myUserId: myUserId,
                    canManage: canManage,
                    ownerId: workspace?.ownerId,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Shown when there's no [WorkspaceService] (signed out / Supabase off): admin
/// actions need the network + an account, so explain rather than show controls.
class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined,
              size: 36, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            l10n.teamOfflineTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.teamOfflineBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TeamBody extends StatelessWidget {
  const _TeamBody({
    required this.workspaceId,
    required this.service,
    required this.members,
    required this.myUserId,
    required this.canManage,
    required this.ownerId,
  });

  final String workspaceId;
  final WorkspaceService service;
  final List<WorkspaceMember> members;
  final String? myUserId;
  final bool canManage;
  final String? ownerId;

  bool get _amOwner => myUserId != null && myUserId == ownerId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 20),
      children: [
        // Members section.
        Text(
          l10n.teamMembersSectionHeader,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.teamNoMembers,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final member in members)
            _MemberRow(
              workspaceId: workspaceId,
              service: service,
              member: member,
              isMe: member.userId == myUserId,
              isOwner: member.userId == ownerId,
              canManage: canManage,
            ),

        // Invite section (managers/owners only).
        if (canManage) ...[
          const SizedBox(height: 24),
          Text(
            l10n.teamInviteSectionHeader,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _InviteRow(workspaceId: workspaceId, service: service),
        ],

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Danger / membership actions.
        _MembershipActions(
          workspaceId: workspaceId,
          service: service,
          amOwner: _amOwner,
        ),
      ],
    );
  }
}

/// One member: email + role. Managers/owners see a role dropdown and a remove
/// button (never on themselves or on the owner); everyone else sees a static
/// role chip.
class _MemberRow extends ConsumerStatefulWidget {
  const _MemberRow({
    required this.workspaceId,
    required this.service,
    required this.member,
    required this.isMe,
    required this.isOwner,
    required this.canManage,
  });

  final String workspaceId;
  final WorkspaceService service;
  final WorkspaceMember member;
  final bool isMe;
  final bool isOwner;
  final bool canManage;

  @override
  ConsumerState<_MemberRow> createState() => _MemberRowState();
}

class _MemberRowState extends ConsumerState<_MemberRow> {
  bool _busy = false;

  /// Roles can be edited by a manager/owner, but never the owner's own role and
  /// never your own row (you can't demote yourself out of management here).
  bool get _roleEditable =>
      widget.canManage && !widget.isOwner && !widget.isMe;

  /// Members can be removed by a manager/owner, but not the owner or yourself
  /// (leaving is a separate, explicit action).
  bool get _removable =>
      widget.canManage && !widget.isOwner && !widget.isMe;

  Future<void> _setRole(WorkspaceRole role) async {
    if (role == widget.member.role) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.service.setRole(
        widget.workspaceId,
        widget.member.userId,
        role,
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyWorkspaceError(context, e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.teamRemoveMemberTitle),
        content: Text(
          l10n.teamRemoveMemberBody(widget.member.email),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonRemove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.service.removeMember(widget.workspaceId, widget.member.userId);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamRemovedMemberSnack(widget.member.email))),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyWorkspaceError(context, e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final member = widget.member;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Text(
              _initial(member.email),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    member.email.isEmpty ? l10n.teamMemberUnknownEmail : member.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (widget.isMe) ...[
                  const SizedBox(width: 6),
                  Text(
                    l10n.teamMemberYouLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_roleEditable)
            _RoleDropdown(
              value: member.role,
              onChanged: (r) => r == null ? null : _setRole(r),
            )
          else
            RoleChip(role: member.role),
          if (_removable && !_busy)
            IconButton(
              tooltip: l10n.teamRemoveMemberTooltip,
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              icon: const Icon(Icons.person_remove_outlined),
              onPressed: _remove,
            ),
        ],
      ),
    );
  }

  static String _initial(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

/// The invite row: an email field, a role dropdown, and an Invite button that
/// calls [WorkspaceService.invite]. Surfaces RLS/network errors inline.
class _InviteRow extends ConsumerStatefulWidget {
  const _InviteRow({required this.workspaceId, required this.service});

  final String workspaceId;
  final WorkspaceService service;

  @override
  ConsumerState<_InviteRow> createState() => _InviteRowState();
}

class _InviteRowState extends ConsumerState<_InviteRow> {
  final _emailController = TextEditingController();
  WorkspaceRole _role = WorkspaceRole.member;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = l10n.teamInviteInvalidEmail);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.service.invite(widget.workspaceId, email, _role);
      if (!mounted) return;
      _emailController.clear();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamInvitedSnack(email, _role.wire))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyWorkspaceError(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _busy ? null : _invite(),
                decoration: InputDecoration(
                  hintText: l10n.teamInviteEmailHint,
                  prefixIcon: const Icon(Icons.mail_outline, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _RoleDropdown(
              value: _role,
              onChanged: _busy
                  ? null
                  : (r) => setState(() => _role = r ?? _role),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.icon(
            onPressed: _busy ? null : _invite,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined, size: 18),
            label: Text(l10n.teamInviteButton),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          _TeamError(message: _error!),
        ],
      ],
    );
  }
}

/// "Leave team" for everyone, plus "Delete team" for the owner. Each confirms
/// before acting and pops the dialog on success.
class _MembershipActions extends ConsumerStatefulWidget {
  const _MembershipActions({
    required this.workspaceId,
    required this.service,
    required this.amOwner,
  });

  final String workspaceId;
  final WorkspaceService service;
  final bool amOwner;

  @override
  ConsumerState<_MembershipActions> createState() => _MembershipActionsState();
}

class _MembershipActionsState extends ConsumerState<_MembershipActions> {
  bool _busy = false;

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result == true;
  }

  /// If we just left/deleted the workspace that's currently active, switch the
  /// active library back to Personal so the app doesn't sit on a dead id.
  void _resetActiveIfNeeded() {
    final active = ref.read(activeWorkspaceProvider);
    if (active == widget.workspaceId) {
      ref.read(activeWorkspaceProvider.notifier).setWorkspace(null);
    }
  }

  Future<void> _leave() async {
    final l10n = AppLocalizations.of(context);
    final ok = await _confirm(
      title: l10n.teamLeaveTitle,
      body: l10n.teamLeaveBody,
      action: l10n.teamLeaveAction,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await widget.service.leave(widget.workspaceId);
      _resetActiveIfNeeded();
      if (!mounted) return;
      navigator.maybePop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.teamLeftSnack)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyWorkspaceError(context, e))),
      );
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await _confirm(
      title: l10n.teamDeleteTitle,
      body: l10n.teamDeleteBody,
      action: l10n.commonDelete,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await widget.service.deleteWorkspace(widget.workspaceId);
      _resetActiveIfNeeded();
      if (!mounted) return;
      navigator.maybePop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.teamDeletedSnack)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyWorkspaceError(context, e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (_busy) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _leave,
          icon: const Icon(Icons.logout, size: 18),
          label: Text(l10n.teamLeaveButton),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
          ),
        ),
        const Spacer(),
        if (widget.amOwner)
          TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(l10n.teamDeleteButton),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}

/// A compact dropdown over the four [WorkspaceRole]s.
class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.value, required this.onChanged});

  final WorkspaceRole value;
  final ValueChanged<WorkspaceRole?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<WorkspaceRole>(
        value: value,
        onChanged: onChanged,
        isDense: true,
        borderRadius: BorderRadius.circular(10),
        items: [
          for (final role in WorkspaceRole.values)
            DropdownMenuItem<WorkspaceRole>(
              value: role,
              child: Text(_roleLabel(context, role)),
            ),
        ],
      ),
    );
  }
}

/// A static, tinted role pill for members you can't edit (and for viewing your
/// own role / the owner). Color-coded so privilege levels read at a glance.
class RoleChip extends StatelessWidget {
  const RoleChip({super.key, required this.role});

  final WorkspaceRole role;

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _roleLabel(context, role),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TeamError extends StatelessWidget {
  const _TeamError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

String _roleLabel(BuildContext context, WorkspaceRole role) {
  final l10n = AppLocalizations.of(context);
  switch (role) {
    case WorkspaceRole.owner:
      return l10n.teamRoleOwner;
    case WorkspaceRole.manager:
      return l10n.teamRoleManager;
    case WorkspaceRole.member:
      return l10n.teamRoleMember;
    case WorkspaceRole.viewer:
      return l10n.teamRoleViewer;
  }
}

Color _roleColor(WorkspaceRole role) {
  switch (role) {
    case WorkspaceRole.owner:
      return const Color(0xFF8E4EC6); // purple
    case WorkspaceRole.manager:
      return const Color(0xFF3E63DD); // blue
    case WorkspaceRole.member:
      return const Color(0xFF16B378); // green
    case WorkspaceRole.viewer:
      return const Color(0xFF98A1B0); // grey
  }
}

/// Maps a thrown error into a friendly, user-facing message. RLS denials
/// (Postgres `42501` / PostgREST `PGRST301`/`401`/`403`) become "Only managers
/// can do that"; network problems become a reconnect hint.
String friendlyWorkspaceError(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  if (error is PostgrestException) {
    final code = error.code ?? '';
    final msg = error.message.toLowerCase();
    if (code == '42501' ||
        code == 'PGRST301' ||
        code == '401' ||
        code == '403' ||
        msg.contains('row-level security') ||
        msg.contains('permission denied') ||
        msg.contains('policy')) {
      return l10n.teamErrorOnlyManagers;
    }
    return error.message;
  }
  if (error is StateError) {
    // e.g. "Must be signed in to invite".
    return error.message;
  }
  final text = error.toString().toLowerCase();
  if (text.contains('socket') ||
      text.contains('network') ||
      text.contains('failed host lookup') ||
      text.contains('connection')) {
    return l10n.teamErrorNetworkUnavailable;
  }
  return l10n.teamErrorGeneric;
}

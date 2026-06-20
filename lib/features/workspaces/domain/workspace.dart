// Team-library (workspace) domain types. A workspace is a shared library:
// its members collaborate on content scoped to `workspace_id`. Personal
// content has no workspace (workspace_id == null) and never needs an account.

/// The role a user holds in a workspace. [wire] is the stable string persisted
/// remotely (workspace_members.role) and cached locally — never change these.
enum WorkspaceRole {
  owner('owner'),
  manager('manager'),
  member('member'),
  viewer('viewer');

  const WorkspaceRole(this.wire);

  final String wire;

  /// Roles that may create/edit/delete content in the workspace. `viewer` is
  /// read-only. Mirrors the remote RLS `can_write` predicate.
  bool get canWrite =>
      this == owner || this == manager || this == member;

  /// Roles that may administer the workspace (invite, set roles, remove
  /// members, delete the workspace). RLS enforces this server-side too.
  bool get canManage => this == owner || this == manager;

  static WorkspaceRole fromWire(String? wire) => values.firstWhere(
        (e) => e.wire == wire,
        orElse: () => WorkspaceRole.viewer,
      );
}

/// A team library the current user belongs to. [myRole] is the signed-in user's
/// role in this workspace (null when unknown/not yet refreshed).
class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.ownerId,
    this.myRole,
  });

  final String id;
  final String name;
  final String ownerId;
  final WorkspaceRole? myRole;
}

/// A member of a workspace, for the members/roles management UI.
class WorkspaceMember {
  const WorkspaceMember({
    required this.workspaceId,
    required this.userId,
    required this.email,
    required this.role,
  });

  final String workspaceId;
  final String userId;
  final String email;
  final WorkspaceRole role;
}

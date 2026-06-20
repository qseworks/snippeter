// Private fields can't be named initializing formals, so assign in the body.
// ignore_for_file: prefer_initializing_formals
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/app_database.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/ids.dart';
import '../domain/workspace.dart';

/// ONLINE workspace administration over Supabase, mirrored into the local cache
/// tables (`workspaces`, `workspace_members`) for offline display.
///
/// Workspace ADMIN (create/invite/roles/members/delete) requires the network —
/// these are not part of the offline dirty-content sync. Team CONTENT itself
/// flows through the existing content sync via each row's `workspace_id`.
///
/// All write paths also write the remote; RLS enforces who may do what
/// (manager/owner for admin ops; viewers are read-only). Failures propagate to
/// the caller so the UI can surface them — being offline simply means these
/// admin actions are unavailable until reconnected.
class WorkspaceService {
  WorkspaceService({
    required AppDatabase db,
    required SupabaseClient client,
  })  : _db = db,
        _client = client;

  final AppDatabase _db;
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentSession?.user.id;

  String? get _email => _client.auth.currentSession?.user.email;

  // --- create ----------------------------------------------------------------

  /// Creates a remote workspace, adds the signed-in user as its owner, mirrors
  /// both into the local cache, and returns the new workspace id.
  Future<String> createWorkspace(String name) async {
    final uid = _userId;
    if (uid == null) {
      throw StateError('Must be signed in to create a workspace');
    }
    final id = newId();
    final ts = nowMs();

    // owner_id is server-set; do not send it.
    final inserted = await _client
        .from('workspaces')
        .insert({
          'id': id,
          'name': name,
          'created_at': ts,
          'updated_at': ts,
        })
        .select()
        .single();

    await _client.from('workspace_members').insert({
      'workspace_id': id,
      'user_id': uid,
      'role': WorkspaceRole.owner.wire,
      'email': _email,
      'created_at': ts,
    });

    await _mirrorWorkspace(inserted, myRole: WorkspaceRole.owner.wire);
    await _mirrorMember({
      'workspace_id': id,
      'user_id': uid,
      'role': WorkspaceRole.owner.wire,
      'email': _email ?? '',
      'created_at': ts,
    });
    return id;
  }

  // --- refresh ---------------------------------------------------------------

  /// Pulls every workspace the user can see (RLS scopes it to memberships) plus
  /// their members, and reconciles the local cache to exactly that set.
  Future<void> refreshWorkspaces() async {
    final uid = _userId;
    if (uid == null) return;

    final remoteWorkspaces = (await _client.from('workspaces').select())
        .cast<Map<String, dynamic>>();
    final remoteMembers = (await _client.from('workspace_members').select())
        .cast<Map<String, dynamic>>();

    final myRoleByWs = <String, String>{
      for (final m in remoteMembers)
        if (m['user_id'] == uid)
          m['workspace_id'] as String: m['role'] as String,
    };

    final keepWsIds = {
      for (final w in remoteWorkspaces) w['id'] as String,
    };

    await _db.transaction(() async {
      // Replace the cached workspace set with what RLS returned.
      await (_db.delete(_db.workspaces)
            ..where((w) => keepWsIds.isEmpty
                ? const Constant(true)
                : w.id.isNotIn(keepWsIds.toList())))
          .go();
      for (final w in remoteWorkspaces) {
        await _mirrorWorkspace(w, myRole: myRoleByWs[w['id']]);
      }

      // Replace cached members for the visible workspaces.
      await (_db.delete(_db.workspaceMembers)
            ..where((m) => keepWsIds.isEmpty
                ? const Constant(true)
                : m.workspaceId.isNotIn(keepWsIds.toList())))
          .go();
      for (final m in remoteMembers) {
        await _mirrorMember(m);
      }
    });
  }

  // --- invites ---------------------------------------------------------------

  /// Invites [email] to [wsId] with [role]. RLS allows this only for
  /// owner/manager. The invitee accepts via [acceptPendingInvites] on sign-in.
  Future<void> invite(String wsId, String email, WorkspaceRole role) async {
    final uid = _userId;
    if (uid == null) {
      throw StateError('Must be signed in to invite');
    }
    await _client.from('workspace_invites').insert({
      'id': newId(),
      'workspace_id': wsId,
      'email': email.trim().toLowerCase(),
      'role': role.wire,
      'invited_by': uid,
      'created_at': nowMs(),
    });
  }

  /// Accepts every pending invite addressed to the signed-in user's email:
  /// inserts a membership row remotely, deletes the invite, then refreshes.
  Future<void> acceptPendingInvites() async {
    final uid = _userId;
    final email = _email;
    if (uid == null || email == null) return;

    final invites = (await _client
            .from('workspace_invites')
            .select()
            .eq('email', email.toLowerCase()))
        .cast<Map<String, dynamic>>();
    if (invites.isEmpty) return;

    for (final inv in invites) {
      await _client.from('workspace_members').upsert({
        'workspace_id': inv['workspace_id'],
        'user_id': uid,
        'role': inv['role'],
        'email': email,
        'created_at': nowMs(),
      });
      await _client.from('workspace_invites').delete().eq('id', inv['id']);
    }
    await refreshWorkspaces();
  }

  // --- member management -----------------------------------------------------

  /// Changes [userId]'s role in [wsId] (owner/manager only, per RLS).
  Future<void> setRole(String wsId, String userId, WorkspaceRole role) async {
    await _client
        .from('workspace_members')
        .update({'role': role.wire})
        .eq('workspace_id', wsId)
        .eq('user_id', userId);
    await (_db.update(_db.workspaceMembers)
          ..where((m) => m.workspaceId.equals(wsId) & m.userId.equals(userId)))
        .write(WorkspaceMembersCompanion(role: Value(role.wire)));
  }

  /// Removes [userId] from [wsId] (owner/manager only, per RLS).
  Future<void> removeMember(String wsId, String userId) async {
    await _client
        .from('workspace_members')
        .delete()
        .eq('workspace_id', wsId)
        .eq('user_id', userId);
    await (_db.delete(_db.workspaceMembers)
          ..where((m) => m.workspaceId.equals(wsId) & m.userId.equals(userId)))
        .go();
  }

  /// The signed-in user leaves [wsId]. Mirrors by dropping the cached workspace
  /// and its members locally.
  Future<void> leave(String wsId) async {
    final uid = _userId;
    if (uid == null) return;
    await _client
        .from('workspace_members')
        .delete()
        .eq('workspace_id', wsId)
        .eq('user_id', uid);
    await _dropWorkspaceLocally(wsId);
  }

  /// Owner deletes [wsId]. RLS restricts this to the owner. Drops the cache.
  Future<void> deleteWorkspace(String wsId) async {
    await _client.from('workspaces').delete().eq('id', wsId);
    await _dropWorkspaceLocally(wsId);
  }

  // --- local mirror helpers --------------------------------------------------

  Future<void> _mirrorWorkspace(
    Map<String, dynamic> w, {
    String? myRole,
  }) async {
    await _db.into(_db.workspaces).insertOnConflictUpdate(
          WorkspacesCompanion(
            id: Value(w['id'] as String),
            name: Value(w['name'] as String? ?? ''),
            ownerId: Value(w['owner_id'] as String? ?? ''),
            role: Value(myRole),
            createdAt: Value((w['created_at'] as num?)?.toInt() ?? 0),
            updatedAt: Value((w['updated_at'] as num?)?.toInt() ?? 0),
            deletedAt: Value((w['deleted_at'] as num?)?.toInt()),
            dirty: const Value(false),
          ),
        );
  }

  Future<void> _mirrorMember(Map<String, dynamic> m) async {
    await _db.into(_db.workspaceMembers).insertOnConflictUpdate(
          WorkspaceMembersCompanion(
            workspaceId: Value(m['workspace_id'] as String),
            userId: Value(m['user_id'] as String),
            email: Value(m['email'] as String? ?? ''),
            role: Value(m['role'] as String? ?? WorkspaceRole.viewer.wire),
            createdAt: Value((m['created_at'] as num?)?.toInt() ?? 0),
          ),
        );
  }

  Future<void> _dropWorkspaceLocally(String wsId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.workspaceMembers)
            ..where((m) => m.workspaceId.equals(wsId)))
          .go();
      await (_db.delete(_db.workspaces)..where((w) => w.id.equals(wsId))).go();
    });
  }
}

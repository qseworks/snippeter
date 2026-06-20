import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../../settings/application/settings_providers.dart';
import '../data/workspace_service.dart';
import '../domain/workspace.dart';

/// SharedPreferences key for the persisted active-library choice.
const _kActiveWorkspace = 'workspaces.active';

/// The online workspace-admin service, or null when signed out / Supabase
/// isn't configured. The UI treats null as "team admin unavailable".
final workspaceServiceProvider = Provider<WorkspaceService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  // Only meaningful when signed in; mirror auth so it nulls out on sign-out.
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return WorkspaceService(
    db: ref.watch(appDatabaseProvider),
    client: client,
  );
});

/// The active library: null = Personal (offline, no account), else a workspace
/// id. Persisted in SharedPreferences so the choice survives restarts.
class ActiveWorkspaceController extends Notifier<String?> {
  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_kActiveWorkspace);
  }

  /// Switches the active library. Pass null for Personal.
  void setWorkspace(String? workspaceId) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (workspaceId == null) {
      prefs.remove(_kActiveWorkspace);
    } else {
      prefs.setString(_kActiveWorkspace, workspaceId);
    }
    state = workspaceId;
  }
}

/// null = Personal; otherwise the active team workspace id.
final activeWorkspaceProvider =
    NotifierProvider<ActiveWorkspaceController, String?>(
  ActiveWorkspaceController.new,
);

/// Live list of cached workspaces (team libraries) the user belongs to, watched
/// from the local cache table so it works offline. [Workspace.myRole] reflects
/// the cached role.
final workspacesProvider = StreamProvider<List<Workspace>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.workspaces)
    ..where((w) => w.deletedAt.isNull())
    ..orderBy([(w) => OrderingTerm.asc(w.name)]);
  return query.watch().map(
        (rows) => [
          for (final r in rows)
            Workspace(
              id: r.id,
              name: r.name,
              ownerId: r.ownerId,
              myRole: r.role == null ? null : WorkspaceRole.fromWire(r.role),
            ),
        ],
      );
});

/// Live members of a workspace from the local cache, keyed by workspace id.
final workspaceMembersProvider =
    StreamProvider.family<List<WorkspaceMember>, String>((ref, wsId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.workspaceMembers)
    ..where((m) => m.workspaceId.equals(wsId))
    ..orderBy([(m) => OrderingTerm.asc(m.email)]);
  return query.watch().map(
        (rows) => [
          for (final r in rows)
            WorkspaceMember(
              workspaceId: r.workspaceId,
              userId: r.userId,
              email: r.email,
              role: WorkspaceRole.fromWire(r.role),
            ),
        ],
      );
});

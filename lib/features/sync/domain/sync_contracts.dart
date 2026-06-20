import '../../snippets/domain/snippet.dart';

// ===========================================================================
// FUTURE (Phase 7 — designed, DEFERRED). Nothing here is wired into the running
// app yet. These contracts exist so cloud sync can be added later as a purely
// ADDITIVE change, behind the existing SnippetRepository seam, without touching
// the UI or state layers.
//
// Planned Supabase backing:
//  - Every local table mirrors 1:1 to Postgres (TEXT id -> uuid, INTEGER epoch
//    -> timestamptz, JSON -> jsonb). The local FTS5 index stays LOCAL-ONLY;
//    Postgres uses tsvector + GIN behind the same repository search method.
//  - Row-Level Security on every table: `(select auth.uid()) = owner_id`
//    (the select-wrapper is the documented performant form).
//  - Share-by-link via a separate `shared_snippets` token table read through a
//    SECURITY DEFINER RPC, so the main table is never exposed publicly.
//  - Durability is owned by a Drift-backed OUTBOX table, NOT Riverpod 3's
//    experimental offline persistence.
// ===========================================================================

/// A single queued local mutation (one outbox row). [opId] is a UUID used as
/// the idempotency key for upsert-on-id, so retries are safe.
class SyncOp {
  const SyncOp({
    required this.opId,
    required this.entityId,
    required this.kind,
    required this.payload,
    required this.createdAt,
  });

  final String opId;
  final String entityId;
  final SyncOpKind kind;
  final Map<String, Object?> payload;
  final int createdAt;
}

enum SyncOpKind { upsert, delete }

enum SyncStatus { idle, syncing, offline, error }

/// The remote half of sync (Supabase). Deferred — not implemented.
abstract interface class RemoteSnippetDataSource {
  /// Pull rows changed since the last watermark (epoch-ms).
  Future<List<Snippet>> fetchChangedSince(int watermarkMs);

  /// Push queued outbox operations; the op UUID is the idempotency key.
  Future<void> push(List<SyncOp> ops);
}

/// Drains the outbox to the remote and pulls remote changes. Conflict
/// resolution is row-level Last-Write-Wins with a DETERMINISTIC tiebreaker:
/// compare `updatedAt`, then break same-millisecond ties on `opId` (then
/// `owner_id`) so every device converges to the same winner; the losing version
/// is kept as a conflict copy rather than discarded. Deferred — not implemented.
abstract interface class SyncEngine {
  Future<void> sync();
  Stream<SyncStatus> watchStatus();
}

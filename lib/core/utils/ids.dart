import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a time-ordered **UUIDv7** primary key.
///
/// UUIDv7 (not autoincrement) is non-negotiable for sync-readiness: two offline
/// devices can mint IDs that never collide, while the embedded timestamp keeps
/// the B-tree index locally well-ordered. Maps 1:1 to a Postgres `uuid` later.
String newId() => _uuid.v7();

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Single source of the [AppDatabase] instance. Repositories depend on this;
/// the rest of the app never touches Drift directly.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

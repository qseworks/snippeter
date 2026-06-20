import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/database_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../../settings/application/settings_providers.dart';
import '../data/supabase_sync_service.dart';

/// The sync engine, or null when Supabase isn't configured/available. keepAlive
/// so realtime channels and the debounce timer survive widget rebuilds.
final syncServiceProvider = Provider<SupabaseSyncService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  final service = SupabaseSyncService(
    db: ref.watch(appDatabaseProvider),
    client: client,
    prefs: ref.watch(sharedPreferencesProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Bridges auth -> sync lifecycle. Watch this once at app start (see app.dart):
///   * SIGNED_IN  -> service.start() + syncOnce()
///   * SIGNED_OUT -> service.stop()
/// No-op when Supabase isn't configured. The app never gates on auth.
final syncBootstrapProvider = Provider<void>((ref) {
  final service = ref.watch(syncServiceProvider);
  if (service == null) return;

  ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
    final event = next.value?.event;
    if (event == null) return;
    switch (event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.initialSession:
        if (next.value?.session != null) {
          service.start();
          service.syncOnce();
        }
      case AuthChangeEvent.signedOut:
        service.stop();
      default:
        break;
    }
  }, fireImmediately: true);
});

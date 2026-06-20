import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../data/auth_service.dart';

/// The Supabase client, or null when the backend isn't configured/initialized.
/// Everything auth/sync-related treats null as "offline only".
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    // Supabase.initialize was never called (e.g. tests) — stay offline.
    return null;
  }
});

/// The auth service, or null when Supabase isn't available.
final authServiceProvider = Provider<AuthService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return AuthService(client);
});

/// Streams auth transitions. Stays in the loading/empty state when offline.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  if (auth == null) return const Stream.empty();
  return auth.onAuthStateChange;
});

/// The currently signed-in user, or null. Reactively recomputed as auth changes.
final currentUserProvider = Provider<User?>((ref) {
  // Re-read whenever auth state changes so dependents rebuild on sign in/out.
  ref.watch(authStateProvider);
  final auth = ref.watch(authServiceProvider);
  return auth?.currentUser;
});

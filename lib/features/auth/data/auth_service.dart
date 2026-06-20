import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper over the Supabase auth client. Keeps the UI/state layers free of
/// the `supabase_flutter` types beyond [User]/[AuthState], and makes auth easy
/// to stub in tests. Email/password only for this cut.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  /// The current authenticated user, or null when signed out.
  User? get currentUser => _auth.currentSession?.user;

  /// Emits on every auth transition (signed in / out / token refreshed).
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) =>
      _auth.signUp(email: email, password: password);

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) =>
      _auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();
}

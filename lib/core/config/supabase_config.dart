/// Compile-time Supabase connection config.
///
/// The app is **offline-first**, so there is no backend by default: with these
/// unset, [isConfigured] is false and the app runs fully on the local Drift
/// database. Opt into a backend at build time with
/// `--dart-define SUPABASE_URL=... --dart-define SUPABASE_ANON_KEY=...`.
///
/// For local development, `scripts/dev-local.sh` injects the local Docker
/// stack's URL + key automatically. When you stand up a new hosted project,
/// either pass those defines in your build/CI or set the defaults below.
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Public reader URL for a snippet, served by the `share` edge function
  /// (resolves against whatever backend is configured).
  static String shareUrl(String snippetId) =>
      '$url/functions/v1/share?id=$snippetId';
}

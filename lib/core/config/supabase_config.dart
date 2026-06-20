/// Compile-time Supabase connection config.
///
/// Provide real values at build time with `--dart-define SUPABASE_URL=... ` and
/// `--dart-define SUPABASE_ANON_KEY=...`; the defaults below point at the
/// project's dev instance so the app works out of the box. When neither is set
/// (e.g. in some CI/test contexts) [isConfigured] is false and the app simply
/// runs fully offline — local Drift remains the source of truth either way.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xxxxxxxxxxxxxxxxxxxx.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_REDACTED',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Public reader URL for a snippet, served by the `share` edge function.
  /// Resolves once that function is deployed (see `supabase/functions/share`).
  static String shareUrl(String snippetId) =>
      '$url/functions/v1/share?id=$snippetId';
}

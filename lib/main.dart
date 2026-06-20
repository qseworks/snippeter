import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'features/settings/application/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Optional cloud backend. The app is offline-first: if Supabase isn't
  // configured (or initialization fails, e.g. no network), we carry on with the
  // local Drift database as the single source of truth.
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // The configured key is a publishable key; pass it via the non-
        // deprecated `publishableKey` param (interchangeable with `anonKey`).
        publishableKey: SupabaseConfig.anonKey,
      );
    } catch (_) {
      // Swallow: sign-in/sync stay unavailable, local app keeps working.
    }
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SnippetManagerApp(),
    ),
  );
}

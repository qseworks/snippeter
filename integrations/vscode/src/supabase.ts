import { createClient, SupabaseClient } from "@supabase/supabase-js";

// Baked-in project credentials (anon / publishable key is safe to ship in clients).
// RLS on the server scopes every read/write to the signed-in user and their teams.
const SUPABASE_URL = "https://xxxxxxxxxxxxxxxxxxxx.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_REDACTED";

let client: SupabaseClient | undefined;

/**
 * Returns a singleton Supabase client. The extension never persists the session
 * via Supabase's own storage; we manage it ourselves through context.secrets, so
 * auto-refresh/persist are disabled here.
 */
export function getSupabase(): SupabaseClient {
  if (!client) {
    client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      auth: {
        persistSession: false,
        autoRefreshToken: true,
        detectSessionInUrl: false,
      },
    });
  }
  return client;
}

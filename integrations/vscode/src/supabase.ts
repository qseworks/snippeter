import * as vscode from "vscode";
import { createClient, SupabaseClient } from "@supabase/supabase-js";

// Connection defaults to the local dev stack (`supabase start`). Override via the
// `snippetManager.supabaseUrl` / `snippetManager.supabaseAnonKey` settings to
// target a hosted project. The anon/publishable key is safe to ship — all access
// is gated by Supabase Auth + Row Level Security.
const DEFAULT_URL = "http://127.0.0.1:55321";
const DEFAULT_ANON_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";

let client: SupabaseClient | undefined;

// Rebuild the client when the connection settings change mid-session.
vscode.workspace.onDidChangeConfiguration((e) => {
  if (
    e.affectsConfiguration("snippetManager.supabaseUrl") ||
    e.affectsConfiguration("snippetManager.supabaseAnonKey")
  ) {
    client = undefined;
  }
});

/**
 * Returns a singleton Supabase client built from the configured URL + key. The
 * extension never persists the session via Supabase's own storage; we manage it
 * ourselves through context.secrets, so auto-refresh/persist are disabled here.
 */
export function getSupabase(): SupabaseClient {
  if (!client) {
    const cfg = vscode.workspace.getConfiguration("snippetManager");
    const url = cfg.get<string>("supabaseUrl")?.trim() || DEFAULT_URL;
    const anonKey = cfg.get<string>("supabaseAnonKey")?.trim() || DEFAULT_ANON_KEY;
    client = createClient(url, anonKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: true,
        detectSessionInUrl: false,
      },
    });
  }
  return client;
}

import { homedir } from "node:os";
import { join } from "node:path";

/**
 * Default Supabase connection — the local dev stack (`supabase start`, see
 * ../../../docs/local-dev.md). These are public (anon/publishable) values, safe
 * to bake in. Point at a hosted project by overriding both via env:
 *   SNIPPET_SUPABASE_URL=https://<your-project-ref>.supabase.co
 *   SNIPPET_SUPABASE_ANON_KEY=<its-publishable-key>
 */
export const DEFAULT_SUPABASE_URL = "http://127.0.0.1:55321";
export const DEFAULT_SUPABASE_ANON_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";

export function getSupabaseUrl(): string {
  return process.env.SNIPPET_SUPABASE_URL ?? DEFAULT_SUPABASE_URL;
}

export function getSupabaseAnonKey(): string {
  return process.env.SNIPPET_SUPABASE_ANON_KEY ?? DEFAULT_SUPABASE_ANON_KEY;
}

/** Directory where the CLI stores its session credentials. */
export function configDir(): string {
  return join(homedir(), ".config", "snippet-manager");
}

/** Path to the persisted session file. */
export function credentialsPath(): string {
  return join(configDir(), "credentials.json");
}

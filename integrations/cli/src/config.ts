import { homedir } from "node:os";
import { join } from "node:path";

/**
 * Default Supabase project connection. These are public (anon/publishable)
 * values and are safe to bake into the client. Both are overridable via env.
 */
export const DEFAULT_SUPABASE_URL = "https://xxxxxxxxxxxxxxxxxxxx.supabase.co";
export const DEFAULT_SUPABASE_ANON_KEY =
  "sb_publishable_REDACTED";

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

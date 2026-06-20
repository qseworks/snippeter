import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { getSupabaseAnonKey, getSupabaseUrl } from "./config.js";
import { loadSession, saveSession } from "./session.js";

/** Create a fresh Supabase client. We manage persistence ourselves. */
export function makeClient(): SupabaseClient {
  return createClient(getSupabaseUrl(), getSupabaseAnonKey(), {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false,
    },
  });
}

/**
 * Build a client and restore the saved session (if any) via setSession.
 * If supabase refreshes the tokens during restore, the new tokens are
 * written back to disk so the next invocation keeps working.
 *
 * Returns the client plus whether an authenticated session was restored.
 */
export async function makeAuthedClient(): Promise<{
  client: SupabaseClient;
  authenticated: boolean;
}> {
  const client = makeClient();
  const saved = await loadSession();
  if (!saved) {
    return { client, authenticated: false };
  }

  const { data, error } = await client.auth.setSession({
    access_token: saved.access_token,
    refresh_token: saved.refresh_token,
  });

  if (error || !data.session) {
    return { client, authenticated: false };
  }

  // Persist refreshed tokens if they changed (e.g. access token rotated).
  if (
    data.session.access_token !== saved.access_token ||
    data.session.refresh_token !== saved.refresh_token
  ) {
    await saveSession({
      access_token: data.session.access_token,
      refresh_token: data.session.refresh_token,
      email: data.session.user?.email ?? saved.email,
    });
  }

  return { client, authenticated: true };
}

/**
 * Like makeAuthedClient but exits the process with a helpful message when
 * the user is not signed in. Use for commands that require auth.
 */
export async function requireAuthedClient(): Promise<SupabaseClient> {
  const { client, authenticated } = await makeAuthedClient();
  if (!authenticated) {
    console.error("Not signed in. Run `snip login` first.");
    process.exit(1);
  }
  return client;
}

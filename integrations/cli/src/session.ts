import { chmod, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { configDir, credentialsPath } from "./config.js";

/** Minimal shape of what we persist to disk. */
export interface SavedSession {
  access_token: string;
  refresh_token: string;
  /** Email is stored for a fast `whoami` without a network round-trip. */
  email?: string;
}

/**
 * Persist the session tokens to ~/.config/snippet-manager/credentials.json
 * with 0600 permissions (owner read/write only).
 */
export async function saveSession(session: SavedSession): Promise<void> {
  await mkdir(configDir(), { recursive: true, mode: 0o700 });
  const path = credentialsPath();
  await writeFile(path, JSON.stringify(session, null, 2), { mode: 0o600 });
  // Ensure perms are 600 even if the file already existed with looser perms.
  await chmod(path, 0o600);
}

/** Load the saved session, or null if none exists / it is unreadable. */
export async function loadSession(): Promise<SavedSession | null> {
  try {
    const raw = await readFile(credentialsPath(), "utf8");
    const parsed = JSON.parse(raw) as Partial<SavedSession>;
    if (
      typeof parsed.access_token === "string" &&
      typeof parsed.refresh_token === "string"
    ) {
      return {
        access_token: parsed.access_token,
        refresh_token: parsed.refresh_token,
        email: typeof parsed.email === "string" ? parsed.email : undefined,
      };
    }
    return null;
  } catch {
    return null;
  }
}

/** Remove the saved session file (no error if it does not exist). */
export async function clearSession(): Promise<void> {
  await rm(credentialsPath(), { force: true });
}

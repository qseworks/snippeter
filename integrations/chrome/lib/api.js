// Snippeter REST client (PostgREST + GoTrue).
// Dependency-free ES module. Talks to Supabase directly via fetch.
// Session (access_token / refresh_token) is persisted in chrome.storage.local.

const SUPABASE_URL = "https://xxxxxxxxxxxxxxxxxxxx.supabase.co";
// Publishable / anon key — safe to embed in clients.
const ANON_KEY = "sb_publishable_REDACTED";

const REST_BASE = `${SUPABASE_URL}/rest/v1`;
const AUTH_BASE = `${SUPABASE_URL}/auth/v1`;

const SESSION_KEY = "snippeter.session";

// ---------------------------------------------------------------------------
// Session storage helpers
// ---------------------------------------------------------------------------

/**
 * Reads the persisted session from chrome.storage.local.
 * @returns {Promise<{access_token:string, refresh_token:string, user?:object}|null>}
 */
export async function getSession() {
  const data = await chrome.storage.local.get(SESSION_KEY);
  return data[SESSION_KEY] || null;
}

/**
 * Persists (or clears) the session in chrome.storage.local.
 * @param {object|null} session
 */
export async function setSession(session) {
  if (session) {
    await chrome.storage.local.set({ [SESSION_KEY]: session });
  } else {
    await chrome.storage.local.remove(SESSION_KEY);
  }
}

/**
 * @returns {Promise<boolean>} true when a usable session exists.
 */
export async function isSignedIn() {
  const session = await getSession();
  return !!(session && session.access_token);
}

// ---------------------------------------------------------------------------
// Low-level request helpers
// ---------------------------------------------------------------------------

function authHeaders(accessToken, extra = {}) {
  return {
    apikey: ANON_KEY,
    Authorization: `Bearer ${accessToken}`,
    "Content-Type": "application/json",
    ...extra,
  };
}

/**
 * Performs an authenticated fetch against PostgREST. On a 401 it refreshes the
 * session once and retries the original request.
 *
 * @param {string} path  Path relative to the REST base, e.g. "/snippets?..."
 * @param {RequestInit} options
 * @returns {Promise<Response>}
 */
async function authedFetch(path, options = {}, retry = true) {
  let session = await getSession();
  if (!session || !session.access_token) {
    throw new ApiError("Not signed in.", 401);
  }

  const doFetch = (token) =>
    fetch(`${REST_BASE}${path}`, {
      ...options,
      headers: authHeaders(token, options.headers || {}),
    });

  let res = await doFetch(session.access_token);

  if (res.status === 401 && retry && session.refresh_token) {
    // Token likely expired — refresh once and retry.
    const refreshed = await refreshSession(session.refresh_token);
    if (refreshed) {
      res = await doFetch(refreshed.access_token);
    }
  }

  return res;
}

// ---------------------------------------------------------------------------
// Auth (GoTrue)
// ---------------------------------------------------------------------------

/**
 * Signs in with email + password. Persists the session on success.
 * @param {string} email
 * @param {string} password
 * @returns {Promise<object>} the stored session
 */
export async function signInWithPassword(email, password) {
  const res = await fetch(`${AUTH_BASE}/token?grant_type=password`, {
    method: "POST",
    headers: {
      apikey: ANON_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ email, password }),
  });

  const json = await safeJson(res);
  if (!res.ok) {
    const msg =
      json?.error_description ||
      json?.msg ||
      json?.message ||
      "Sign in failed. Check your email and password.";
    throw new ApiError(msg, res.status);
  }

  const session = {
    access_token: json.access_token,
    refresh_token: json.refresh_token,
    expires_at: json.expires_at,
    user: json.user,
  };
  await setSession(session);
  return session;
}

/**
 * Exchanges a refresh token for a fresh access token. Persists the new session,
 * or clears it (and returns null) if the refresh fails.
 * @param {string} [refreshToken]
 * @returns {Promise<object|null>} the refreshed session, or null
 */
export async function refreshSession(refreshToken) {
  if (!refreshToken) {
    const existing = await getSession();
    refreshToken = existing?.refresh_token;
  }
  if (!refreshToken) return null;

  const res = await fetch(`${AUTH_BASE}/token?grant_type=refresh_token`, {
    method: "POST",
    headers: {
      apikey: ANON_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ refresh_token: refreshToken }),
  });

  const json = await safeJson(res);
  if (!res.ok || !json?.access_token) {
    // Refresh token is invalid/expired — force re-auth.
    await setSession(null);
    return null;
  }

  const session = {
    access_token: json.access_token,
    refresh_token: json.refresh_token,
    expires_at: json.expires_at,
    user: json.user,
  };
  await setSession(session);
  return session;
}

/**
 * Clears the local session (sign out). Best-effort GoTrue logout.
 */
export async function signOut() {
  const session = await getSession();
  if (session?.access_token) {
    try {
      await fetch(`${AUTH_BASE}/logout`, {
        method: "POST",
        headers: authHeaders(session.access_token),
      });
    } catch (_) {
      // Network errors on logout are non-fatal — local clear is what matters.
    }
  }
  await setSession(null);
}

// ---------------------------------------------------------------------------
// Data (PostgREST)
// ---------------------------------------------------------------------------

const SNIPPET_COLUMNS =
  "id,title,body,type,language_id,description,visibility,is_favorite,created_at,updated_at,workspace_id";

const FILE_COLUMNS =
  "id,snippet_id,filename,language_id,content,position";

/**
 * Fetches the signed-in user's snippets (RLS-scoped), newest first.
 * @returns {Promise<Array<object>>}
 */
export async function getSnippets() {
  const path =
    `/snippets?select=${SNIPPET_COLUMNS}` +
    `&deleted_at=is.null&order=updated_at.desc`;
  const res = await authedFetch(path, { method: "GET" });
  if (!res.ok) {
    throw new ApiError(await errText(res, "Failed to load snippets."), res.status);
  }
  return res.json();
}

/**
 * Fetches the files attached to a snippet, ordered by position.
 * @param {string} snippetId
 * @returns {Promise<Array<object>>}
 */
export async function getSnippetFiles(snippetId) {
  const path =
    `/snippet_files?select=${FILE_COLUMNS}` +
    `&snippet_id=eq.${encodeURIComponent(snippetId)}` +
    `&deleted_at=is.null&order=position.asc`;
  const res = await authedFetch(path, { method: "GET" });
  if (!res.ok) {
    throw new ApiError(await errText(res, "Failed to load snippet files."), res.status);
  }
  return res.json();
}

/**
 * Creates a snippet plus its first file. The snippet's `body` mirrors the
 * first file's content. `owner_id` is intentionally omitted (server default).
 *
 * @param {object} params
 * @param {string} params.title
 * @param {string} params.content
 * @param {string} [params.languageId="plaintext"]
 * @param {string} [params.description=""]
 * @param {string} [params.filename]
 * @returns {Promise<{id:string, fileId:string}>}
 */
export async function createSnippet({
  title,
  content,
  languageId = "plaintext",
  description = "",
  filename,
}) {
  const now = Date.now();
  const snippetId = uuid();
  const fileId = uuid();
  const safeTitle = (title && title.trim()) || "Untitled snippet";

  // 1) Insert the snippet row (body mirrors the first file's content).
  const snippetRes = await authedFetch("/snippets", {
    method: "POST",
    headers: { Prefer: "return=minimal" },
    body: JSON.stringify({
      id: snippetId,
      title: safeTitle,
      body: content,
      // The app's snippet types are 'code' | 'text' | 'ai_prompt'; a saved code
      // selection is 'code' (the server default is also 'code').
      type: "code",
      language_id: languageId,
      description,
      visibility: "private",
      is_favorite: false,
      created_at: now,
      updated_at: now,
    }),
  });
  if (!snippetRes.ok) {
    throw new ApiError(
      await errText(snippetRes, "Failed to create snippet."),
      snippetRes.status
    );
  }

  // 2) Insert the backing file at position 0.
  const fileRes = await authedFetch("/snippet_files", {
    method: "POST",
    headers: { Prefer: "return=minimal" },
    body: JSON.stringify({
      id: fileId,
      snippet_id: snippetId,
      filename: filename || defaultFilename(safeTitle, languageId),
      language_id: languageId,
      content,
      position: 0,
      created_at: now,
      updated_at: now,
    }),
  });
  if (!fileRes.ok) {
    throw new ApiError(
      await errText(fileRes, "Snippet created but file failed to save."),
      fileRes.status
    );
  }

  return { id: snippetId, fileId };
}

// ---------------------------------------------------------------------------
// Utilities
// ---------------------------------------------------------------------------

/** RFC4122 v4 UUID using the platform crypto when available. */
export function uuid() {
  if (typeof crypto !== "undefined" && typeof crypto.randomUUID === "function") {
    return crypto.randomUUID();
  }
  // Fallback (e.g. older runtimes).
  const buf = new Uint8Array(16);
  crypto.getRandomValues(buf);
  buf[6] = (buf[6] & 0x0f) | 0x40;
  buf[8] = (buf[8] & 0x3f) | 0x80;
  const hex = [...buf].map((b) => b.toString(16).padStart(2, "0"));
  return (
    hex.slice(0, 4).join("") +
    "-" +
    hex.slice(4, 6).join("") +
    "-" +
    hex.slice(6, 8).join("") +
    "-" +
    hex.slice(8, 10).join("") +
    "-" +
    hex.slice(10, 16).join("")
  );
}

function defaultFilename(title, languageId) {
  const ext = EXT_BY_LANG[languageId] || "txt";
  const slug =
    title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .slice(0, 40) || "snippet";
  return `${slug}.${ext}`;
}

const EXT_BY_LANG = {
  javascript: "js",
  typescript: "ts",
  jsx: "jsx",
  tsx: "tsx",
  python: "py",
  dart: "dart",
  go: "go",
  rust: "rs",
  java: "java",
  kotlin: "kt",
  swift: "swift",
  c: "c",
  cpp: "cpp",
  csharp: "cs",
  ruby: "rb",
  php: "php",
  html: "html",
  css: "css",
  scss: "scss",
  json: "json",
  yaml: "yaml",
  markdown: "md",
  sql: "sql",
  shell: "sh",
  bash: "sh",
  plaintext: "txt",
};

class ApiError extends Error {
  constructor(message, status) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

export { ApiError };

async function safeJson(res) {
  try {
    return await res.json();
  } catch (_) {
    return null;
  }
}

async function errText(res, fallback) {
  const json = await safeJson(res);
  return (
    json?.message ||
    json?.error_description ||
    json?.error ||
    json?.hint ||
    fallback
  );
}

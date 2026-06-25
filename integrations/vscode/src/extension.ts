import * as vscode from "vscode";
import * as path from "path";
import { getSupabase } from "./supabase";

const SESSION_SECRET_KEY = "snippetManager.session";

// ---- Data shapes (only the columns we read) ----
interface SnippetRow {
  id: string;
  title: string;
  body: string | null;
  type: string | null;
  language_id: string | null;
  description: string | null;
  visibility: string | null;
  is_favorite: boolean | null;
  created_at: number | null;
  updated_at: number | null;
  workspace_id: string | null;
}

interface SnippetFileRow {
  id: string;
  snippet_id: string;
  filename: string | null;
  language_id: string | null;
  content: string | null;
  position: number | null;
}

export function activate(context: vscode.ExtensionContext): void {
  // Restore a previously stored session so the user stays signed in across reloads.
  void restoreSession(context);

  context.subscriptions.push(
    vscode.commands.registerCommand("snippetManager.signIn", () =>
      signIn(context)
    ),
    vscode.commands.registerCommand("snippetManager.insertSnippet", () =>
      insertSnippet(context)
    ),
    vscode.commands.registerCommand("snippetManager.saveSelection", () =>
      saveSelection(context)
    )
  );
}

export function deactivate(): void {
  // no-op
}

// ---------------------------------------------------------------------------
// Session handling
// ---------------------------------------------------------------------------

async function restoreSession(context: vscode.ExtensionContext): Promise<void> {
  const stored = await context.secrets.get(SESSION_SECRET_KEY);
  if (!stored) {
    return;
  }
  try {
    const session = JSON.parse(stored) as {
      access_token: string;
      refresh_token: string;
    };
    if (session?.access_token && session?.refresh_token) {
      await getSupabase().auth.setSession({
        access_token: session.access_token,
        refresh_token: session.refresh_token,
      });
    }
  } catch {
    // Corrupt/expired stored session: drop it silently.
    await context.secrets.delete(SESSION_SECRET_KEY);
  }
}

/**
 * Ensures we have an authenticated session. Returns true if signed in, otherwise
 * prompts the user to run the sign-in command and returns false.
 */
async function ensureSignedIn(
  context: vscode.ExtensionContext
): Promise<boolean> {
  const { data } = await getSupabase().auth.getSession();
  if (data.session) {
    return true;
  }
  // Try restoring once more in case activation race left it unset.
  await restoreSession(context);
  const retry = await getSupabase().auth.getSession();
  if (retry.data.session) {
    return true;
  }
  vscode.window.showWarningMessage(
    "Snippeter: Please sign in first (run \"Snippeter: Sign In\")."
  );
  return false;
}

// ---------------------------------------------------------------------------
// Commands
// ---------------------------------------------------------------------------

async function signIn(context: vscode.ExtensionContext): Promise<void> {
  const email = await vscode.window.showInputBox({
    prompt: "Snippeter email",
    placeHolder: "you@example.com",
    ignoreFocusOut: true,
  });
  if (!email) {
    return;
  }

  const password = await vscode.window.showInputBox({
    prompt: "Snippeter password",
    password: true,
    ignoreFocusOut: true,
  });
  if (!password) {
    return;
  }

  try {
    const { data, error } = await getSupabase().auth.signInWithPassword({
      email,
      password,
    });
    if (error || !data.session) {
      vscode.window.showErrorMessage(
        `Snippeter: Sign in failed - ${error?.message ?? "no session returned"}`
      );
      return;
    }
    await context.secrets.store(
      SESSION_SECRET_KEY,
      JSON.stringify(data.session)
    );
    vscode.window.showInformationMessage(
      `Snippeter: Signed in as ${data.user?.email ?? email}.`
    );
  } catch (err) {
    vscode.window.showErrorMessage(
      `Snippeter: Sign in error - ${errorMessage(err)}`
    );
  }
}

async function insertSnippet(context: vscode.ExtensionContext): Promise<void> {
  if (!(await ensureSignedIn(context))) {
    return;
  }

  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage(
      "Snippeter: Open a file to insert a snippet into."
    );
    return;
  }

  let snippets: SnippetRow[];
  try {
    const { data, error } = await getSupabase()
      .from("snippets")
      .select(
        "id,title,body,type,language_id,description,visibility,is_favorite,created_at,updated_at,workspace_id"
      )
      .is("deleted_at", null)
      .order("updated_at", { ascending: false });
    if (error) {
      throw error;
    }
    snippets = (data ?? []) as SnippetRow[];
  } catch (err) {
    vscode.window.showErrorMessage(
      `Snippeter: Failed to load snippets - ${errorMessage(err)}`
    );
    return;
  }

  if (snippets.length === 0) {
    vscode.window.showInformationMessage("Snippeter: No snippets found.");
    return;
  }

  const picked = await vscode.window.showQuickPick(
    snippets.map((s) => ({
      label: s.title || "(untitled)",
      description: s.language_id ?? undefined,
      detail: s.description ?? undefined,
      snippet: s,
    })),
    { placeHolder: "Select a snippet to insert", matchOnDetail: true }
  );
  if (!picked) {
    return;
  }

  // Fetch the snippet's files ordered by position.
  let files: SnippetFileRow[];
  try {
    const { data, error } = await getSupabase()
      .from("snippet_files")
      .select("id,snippet_id,filename,language_id,content,position")
      .eq("snippet_id", picked.snippet.id)
      .is("deleted_at", null)
      .order("position", { ascending: true });
    if (error) {
      throw error;
    }
    files = (data ?? []) as SnippetFileRow[];
  } catch (err) {
    vscode.window.showErrorMessage(
      `Snippeter: Failed to load snippet files - ${errorMessage(err)}`
    );
    return;
  }

  let content: string | null = null;

  if (files.length === 0) {
    // Fall back to the mirrored body if there are no file rows.
    content = picked.snippet.body ?? "";
  } else if (files.length === 1) {
    content = files[0].content ?? "";
  } else {
    const pickedFile = await vscode.window.showQuickPick(
      files.map((f, idx) => ({
        label: f.filename || `file ${idx + 1}`,
        description: f.language_id ?? undefined,
        file: f,
      })),
      { placeHolder: "Select a file to insert" }
    );
    if (!pickedFile) {
      return;
    }
    content = pickedFile.file.content ?? "";
  }

  const toInsert = content ?? "";
  const ok = await editor.edit((editBuilder) => {
    editBuilder.insert(editor.selection.active, toInsert);
  });
  if (ok) {
    vscode.window.showInformationMessage(
      `Snippeter: Inserted "${picked.snippet.title || "(untitled)"}".`
    );
  } else {
    vscode.window.showErrorMessage(
      "Snippeter: Failed to insert snippet into the editor."
    );
  }
}

async function saveSelection(context: vscode.ExtensionContext): Promise<void> {
  if (!(await ensureSignedIn(context))) {
    return;
  }

  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage(
      "Snippeter: Open a file with content to save as a snippet."
    );
    return;
  }

  const selection = editor.selection;
  const content = selection.isEmpty
    ? editor.document.getText()
    : editor.document.getText(selection);

  if (content.trim().length === 0) {
    vscode.window.showWarningMessage(
      "Snippeter: Nothing to save (selection/document is empty)."
    );
    return;
  }

  const filename = path.basename(
    editor.document.fileName || "untitled.txt"
  );
  const languageId = editor.document.languageId || null;

  const title = await vscode.window.showInputBox({
    prompt: "Snippet title",
    value: filename,
    ignoreFocusOut: true,
  });
  if (!title) {
    return;
  }

  const now = Date.now();
  const snippetId = randomId();
  const fileId = randomId();

  try {
    const supabase = getSupabase();

    // Create the snippet. owner_id is intentionally NOT set (server default).
    // body mirrors the first file's content.
    const { error: snippetError } = await supabase.from("snippets").insert({
      id: snippetId,
      title,
      body: content,
      // App snippet types are 'code' | 'text' | 'ai_prompt'; a saved code
      // selection is 'code' (also the server default).
      type: "code",
      language_id: languageId,
      visibility: "private",
      is_favorite: false,
      created_at: now,
      updated_at: now,
    });
    if (snippetError) {
      throw snippetError;
    }

    // Create the single backing file at position 0.
    const { error: fileError } = await supabase.from("snippet_files").insert({
      id: fileId,
      snippet_id: snippetId,
      filename,
      language_id: languageId,
      content,
      position: 0,
      created_at: now,
      updated_at: now,
    });
    if (fileError) {
      throw fileError;
    }

    vscode.window.showInformationMessage(
      `Snippeter: Saved "${title}".`
    );
  } catch (err) {
    vscode.window.showErrorMessage(
      `Snippeter: Failed to save snippet - ${errorMessage(err)}`
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function randomId(): string {
  // Node 24 / VS Code runtime has the global Web Crypto API.
  return crypto.randomUUID();
}

function errorMessage(err: unknown): string {
  if (err instanceof Error) {
    return err.message;
  }
  if (typeof err === "object" && err !== null && "message" in err) {
    return String((err as { message: unknown }).message);
  }
  return String(err);
}

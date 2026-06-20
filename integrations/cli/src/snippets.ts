import type { SupabaseClient } from "@supabase/supabase-js";

export interface SnippetRow {
  id: string;
  title: string | null;
  body: string | null;
  type: string | null;
  language_id: string | null;
  description: string | null;
  visibility: string | null;
  is_favorite: boolean | null;
  created_at: number | null;
  updated_at: number | null;
  deleted_at: number | null;
  workspace_id: string | null;
}

export interface SnippetFileRow {
  id: string;
  snippet_id: string;
  filename: string | null;
  language_id: string | null;
  content: string | null;
  position: number | null;
  created_at: number | null;
  updated_at: number | null;
  deleted_at: number | null;
}

/** List the current user's non-deleted snippets, newest-updated first. */
export async function listSnippets(
  client: SupabaseClient,
  query?: string,
): Promise<SnippetRow[]> {
  let builder = client
    .from("snippets")
    .select("*")
    .is("deleted_at", null)
    .order("updated_at", { ascending: false });

  if (query && query.length > 0) {
    builder = builder.ilike("title", `%${query}%`);
  }

  const { data, error } = await builder;
  if (error) throw new Error(error.message);
  return (data ?? []) as SnippetRow[];
}

/** Fetch a single non-deleted snippet by id, or null if not found. */
export async function getSnippet(
  client: SupabaseClient,
  id: string,
): Promise<SnippetRow | null> {
  const { data, error } = await client
    .from("snippets")
    .select("*")
    .eq("id", id)
    .is("deleted_at", null)
    .maybeSingle();
  if (error) throw new Error(error.message);
  return (data as SnippetRow | null) ?? null;
}

/** Fetch a snippet's non-deleted files, ordered by position. */
export async function getSnippetFiles(
  client: SupabaseClient,
  snippetId: string,
): Promise<SnippetFileRow[]> {
  const { data, error } = await client
    .from("snippet_files")
    .select("*")
    .eq("snippet_id", snippetId)
    .is("deleted_at", null)
    .order("position", { ascending: true });
  if (error) throw new Error(error.message);
  return (data ?? []) as SnippetFileRow[];
}

/** Count non-deleted files per snippet id (single query). */
export async function countFilesBySnippet(
  client: SupabaseClient,
  snippetIds: string[],
): Promise<Map<string, number>> {
  const counts = new Map<string, number>();
  if (snippetIds.length === 0) return counts;

  const { data, error } = await client
    .from("snippet_files")
    .select("snippet_id")
    .in("snippet_id", snippetIds)
    .is("deleted_at", null);
  if (error) throw new Error(error.message);

  for (const row of (data ?? []) as { snippet_id: string }[]) {
    counts.set(row.snippet_id, (counts.get(row.snippet_id) ?? 0) + 1);
  }
  return counts;
}

export interface NewFileInput {
  filename: string;
  content: string;
}

export interface CreateSnippetInput {
  title: string;
  visibility: "private" | "public";
  files: NewFileInput[];
}

/**
 * Insert a snippet and its files. snippets.body mirrors the first file's
 * content. owner_id is intentionally NOT set (server default). Returns the
 * new snippet id.
 */
export async function createSnippet(
  client: SupabaseClient,
  input: CreateSnippetInput,
): Promise<string> {
  const now = Date.now();
  const snippetId = crypto.randomUUID();
  const firstContent = input.files[0]?.content ?? "";

  const { error: snippetError } = await client.from("snippets").insert({
    id: snippetId,
    title: input.title,
    body: firstContent,
    type: "code",
    visibility: input.visibility,
    is_favorite: false,
    created_at: now,
    updated_at: now,
  });
  if (snippetError) throw new Error(snippetError.message);

  const fileRows = input.files.map((file, index) => ({
    id: crypto.randomUUID(),
    snippet_id: snippetId,
    filename: file.filename,
    content: file.content,
    position: index,
    created_at: now,
    updated_at: now,
  }));

  const { error: filesError } = await client
    .from("snippet_files")
    .insert(fileRows);
  if (filesError) throw new Error(filesError.message);

  return snippetId;
}

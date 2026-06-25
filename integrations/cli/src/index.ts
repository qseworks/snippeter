#!/usr/bin/env node
import { basename } from "node:path";
import { readFile } from "node:fs/promises";

import { makeAuthedClient, makeClient, requireAuthedClient } from "./client.js";
import { clearSession, loadSession, saveSession } from "./session.js";
import { promptLine, promptSecret } from "./prompt.js";
import {
  countFilesBySnippet,
  createSnippet,
  getSnippet,
  getSnippetFiles,
  listSnippets,
  type NewFileInput,
} from "./snippets.js";

const USAGE = `snip — Snippeter CLI

Usage:
  snip login                                  Sign in (prompts for email + password) and save the session
  snip logout                                 Delete the saved session
  snip whoami                                 Print the signed-in email, or "not signed in"
  snip list [--query <text>]                  List your snippets (id, title, #files, updated date)
  snip get <id> [--file <name>]               Print a snippet file's contents to stdout (first file by default)
  snip add <file...> [--title <t>] [--private|--public]
                                              Create a snippet from one or more local files
  snip --help                                 Show this help

Config (overridable via environment):
  SNIPPET_SUPABASE_URL        default https://xxxxxxxxxxxxxxxxxxxx.supabase.co
  SNIPPET_SUPABASE_ANON_KEY   default <baked-in publishable key>

The session is saved to ~/.config/snippet-manager/credentials.json (chmod 600).`;

/** Simple flag/positional parser. Flags are --name [value]; the rest are positionals. */
interface ParsedArgs {
  positionals: string[];
  flags: Map<string, string | boolean>;
}

function parseArgs(
  argv: string[],
  valueFlags: Set<string>,
  boolFlags: Set<string>,
): ParsedArgs {
  const positionals: string[] = [];
  const flags = new Map<string, string | boolean>();

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg.startsWith("--")) {
      const name = arg.slice(2);
      if (boolFlags.has(name)) {
        flags.set(name, true);
      } else if (valueFlags.has(name)) {
        const value = argv[i + 1];
        if (value === undefined) {
          throw new Error(`Flag --${name} requires a value.`);
        }
        flags.set(name, value);
        i++;
      } else {
        throw new Error(`Unknown flag: --${name}`);
      }
    } else {
      positionals.push(arg);
    }
  }

  return { positionals, flags };
}

function formatDate(epochMs: number | null): string {
  if (!epochMs) return "-";
  const d = new Date(epochMs);
  if (Number.isNaN(d.getTime())) return "-";
  return d.toISOString().slice(0, 10);
}

async function cmdLogin(): Promise<void> {
  const client = makeClient();
  const email = await promptLine("Email: ");
  const password = await promptSecret("Password: ");

  if (!email || !password) {
    console.error("Email and password are required.");
    process.exit(1);
  }

  const { data, error } = await client.auth.signInWithPassword({
    email,
    password,
  });

  if (error || !data.session) {
    console.error(`Login failed: ${error?.message ?? "no session returned"}`);
    process.exit(1);
  }

  await saveSession({
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    email: data.session.user?.email ?? email,
  });

  console.log(`Signed in as ${data.session.user?.email ?? email}.`);
}

async function cmdLogout(): Promise<void> {
  await clearSession();
  console.log("Signed out. Saved session removed.");
}

async function cmdWhoami(): Promise<void> {
  const { client, authenticated } = await makeAuthedClient();
  if (!authenticated) {
    console.log("not signed in");
    return;
  }
  const { data } = await client.auth.getUser();
  const email = data.user?.email ?? (await loadSession())?.email;
  console.log(email ?? "not signed in");
}

async function cmdList(argv: string[]): Promise<void> {
  const { flags } = parseArgs(argv, new Set(["query"]), new Set());
  const query = flags.get("query");
  const client = await requireAuthedClient();

  const snippets = await listSnippets(
    client,
    typeof query === "string" ? query : undefined,
  );

  if (snippets.length === 0) {
    console.log("No snippets found.");
    return;
  }

  const counts = await countFilesBySnippet(
    client,
    snippets.map((s) => s.id),
  );

  // Render an aligned table.
  const rows = snippets.map((s) => ({
    id: s.id,
    title: s.title ?? "(untitled)",
    files: String(counts.get(s.id) ?? 0),
    updated: formatDate(s.updated_at),
  }));

  const idW = Math.max(2, ...rows.map((r) => r.id.length));
  const titleW = Math.max(5, ...rows.map((r) => r.title.length));
  const filesW = Math.max(5, ...rows.map((r) => r.files.length));

  const header = `${"ID".padEnd(idW)}  ${"TITLE".padEnd(titleW)}  ${"FILES".padEnd(
    filesW,
  )}  UPDATED`;
  console.log(header);
  for (const r of rows) {
    console.log(
      `${r.id.padEnd(idW)}  ${r.title.padEnd(titleW)}  ${r.files.padEnd(
        filesW,
      )}  ${r.updated}`,
    );
  }
}

async function cmdGet(argv: string[]): Promise<void> {
  const { positionals, flags } = parseArgs(argv, new Set(["file"]), new Set());
  const id = positionals[0];
  if (!id) {
    console.error("Usage: snip get <id> [--file <name>]");
    process.exit(1);
  }

  const client = await requireAuthedClient();
  const snippet = await getSnippet(client, id);
  if (!snippet) {
    console.error(`Snippet not found: ${id}`);
    process.exit(1);
  }

  const files = await getSnippetFiles(client, id);
  if (files.length === 0) {
    // Fall back to the snippet body if there are no file rows.
    process.stdout.write(snippet.body ?? "");
    if (snippet.body && !snippet.body.endsWith("\n")) process.stdout.write("\n");
    return;
  }

  const wanted = flags.get("file");
  let target = files[0];
  if (typeof wanted === "string") {
    const match = files.find((f) => f.filename === wanted);
    if (!match) {
      console.error(
        `File "${wanted}" not found in snippet ${id}. Available: ${files
          .map((f) => f.filename ?? "(unnamed)")
          .join(", ")}`,
      );
      process.exit(1);
    }
    target = match;
  }

  const content = target.content ?? "";
  process.stdout.write(content);
  if (content && !content.endsWith("\n")) process.stdout.write("\n");
}

async function cmdAdd(argv: string[]): Promise<void> {
  const { positionals, flags } = parseArgs(
    argv,
    new Set(["title"]),
    new Set(["private", "public"]),
  );

  if (positionals.length === 0) {
    console.error(
      "Usage: snip add <file...> [--title <t>] [--private|--public]",
    );
    process.exit(1);
  }

  if (flags.get("private") && flags.get("public")) {
    console.error("Choose only one of --private or --public.");
    process.exit(1);
  }

  const visibility: "private" | "public" = flags.get("public")
    ? "public"
    : "private";

  const files: NewFileInput[] = [];
  for (const path of positionals) {
    let content: string;
    try {
      content = await readFile(path, "utf8");
    } catch (err) {
      console.error(
        `Cannot read file "${path}": ${
          err instanceof Error ? err.message : String(err)
        }`,
      );
      process.exit(1);
    }
    files.push({ filename: basename(path), content });
  }

  const titleFlag = flags.get("title");
  const title =
    typeof titleFlag === "string" && titleFlag.length > 0
      ? titleFlag
      : (files[0]?.filename ?? "Untitled snippet");

  const client = await requireAuthedClient();
  const id = await createSnippet(client, { title, visibility, files });

  console.log(`Created snippet ${id} ("${title}") with ${files.length} file(s).`);
  if (visibility === "public") {
    console.log(
      `Visibility: public. Share it from the Snippeter app to generate a public link.`,
    );
  } else {
    console.log(
      `Visibility: private. Set --public on creation (or share from the app) to make it shareable.`,
    );
  }
}

async function main(): Promise<void> {
  const [, , command, ...rest] = process.argv;

  if (!command || command === "--help" || command === "-h" || command === "help") {
    console.log(USAGE);
    process.exit(0);
  }

  try {
    switch (command) {
      case "login":
        await cmdLogin();
        break;
      case "logout":
        await cmdLogout();
        break;
      case "whoami":
        await cmdWhoami();
        break;
      case "list":
        await cmdList(rest);
        break;
      case "get":
        await cmdGet(rest);
        break;
      case "add":
        await cmdAdd(rest);
        break;
      default:
        console.error(`Unknown command: ${command}\n`);
        console.log(USAGE);
        process.exit(1);
    }
  } catch (err) {
    console.error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}

void main();

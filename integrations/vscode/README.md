# Snippet Manager — VS Code Extension

Browse, insert, and save code snippets from your [Snippet Manager](https://xxxxxxxxxxxxxxxxxxxx.supabase.co) account directly inside VS Code. The extension talks to the Supabase REST API (PostgREST) using `@supabase/supabase-js`; Row Level Security on the server scopes everything to your account and your team workspaces.

This folder is **self-contained** — it does not touch the Flutter app.

## Commands

Open the Command Palette (`Cmd/Ctrl+Shift+P`) and run:

| Command | Title | What it does |
| --- | --- | --- |
| `snippetManager.signIn` | **Snippet Manager: Sign In** | Prompts for email + password, signs in, and stores the session securely in VS Code's secret storage. |
| `snippetManager.insertSnippet` | **Snippet Manager: Insert Snippet** | Pick a snippet (and a file, if it has more than one) and insert its content at the cursor. |
| `snippetManager.saveSelection` | **Snippet Manager: Save Selection as Snippet** | Saves the current selection (or the whole document) as a new snippet. |

Your session is stored in `context.secrets` and restored automatically on the next launch, so you only sign in once per machine.

## Build

You need Node and npm installed.

```bash
npm install      # install dependencies
npm run compile  # type-check + emit out/extension.js
```

`npm run compile` runs `tsc -p ./`, producing the compiled output in `out/`.

For an iterative loop you can use `npm run watch`.

## Run / Debug

### Option A — Extension Development Host (F5)

1. Open this `integrations/vscode/` folder in VS Code.
2. Press **F5** (Run > Start Debugging). This launches a new "Extension Development Host" window with the extension loaded.
3. In that window, run **Snippet Manager: Sign In**, then try **Insert Snippet** / **Save Selection as Snippet**.

> The first time, make sure you have run `npm install` and `npm run compile` so `out/extension.js` exists.

### Option B — Install a packaged `.vsix` (optional)

Packaging with `vsce` is **not required**. If you want a shareable build, you can optionally:

```bash
npx @vscode/vsce package
```

Then in VS Code: **Extensions** view > `…` menu > **Install from VSIX…** and select the generated `snippet-manager-0.1.0.vsix`.

## Configuration

The Supabase project URL and the anonymous/publishable key are baked into `src/supabase.ts`. The publishable key is safe to ship in clients — all access is gated by Supabase Auth + Row Level Security.

## How data maps

- A snippet (`snippets`) has 1..N files in `snippet_files`, ordered by `position`.
- A snippet's primary content is its files in `position` order; `snippets.body` mirrors the first file.
- Only non-deleted rows (`deleted_at is null`) are read.
- Timestamps are epoch-millisecond integers; IDs are app-generated UUID strings.
- On insert, `owner_id` is **not** set — the server supplies it by default.

# Snippeter — VS Code Extension

Browse, insert, and save code snippets from your Snippeter account directly inside VS Code. The extension talks to the Supabase REST API (PostgREST) using `@supabase/supabase-js`; Row Level Security on the server scopes everything to your account and your team workspaces.

This folder is **self-contained** — it does not touch the Flutter app.

## Commands

Open the Command Palette (`Cmd/Ctrl+Shift+P`) and run:

| Command | Title | What it does |
| --- | --- | --- |
| `snippetManager.signIn` | **Snippeter: Sign In** | Prompts for email + password, signs in, and stores the session securely in VS Code's secret storage. |
| `snippetManager.insertSnippet` | **Snippeter: Insert Snippet** | Pick a snippet (and a file, if it has more than one) and insert its content at the cursor. |
| `snippetManager.saveSelection` | **Snippeter: Save Selection as Snippet** | Saves the current selection (or the whole document) as a new snippet. |

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
3. In that window, run **Snippeter: Sign In**, then try **Insert Snippet** / **Save Selection as Snippet**.

> The first time, make sure you have run `npm install` and `npm run compile` so `out/extension.js` exists.

### Option B — Install a packaged `.vsix` (optional)

Packaging with `vsce` is **not required**. If you want a shareable build, you can optionally:

```bash
npx @vscode/vsce package
```

Then in VS Code: **Extensions** view > `…` menu > **Install from VSIX…** and select the generated `snippet-manager-0.1.0.vsix`.

## Configuration

The extension defaults to the **local dev stack** (`supabase start`, see [`../../docs/local-dev.md`](../../docs/local-dev.md)). To point it at a hosted project, set these in VS Code **Settings** (search "Snippeter"):

| Setting | Default |
| --- | --- |
| `snippetManager.supabaseUrl` | `http://127.0.0.1:55321` |
| `snippetManager.supabaseAnonKey` | local stack anon key |

The publishable/anon key is safe to store in settings — all access is gated by Supabase Auth + Row Level Security.

## Branding

The marketplace icon is `icon.png` (128×128). The Snippeter accent is the brand
green **`#65EA92`** (the block caret); the dark tile / gallery banner background is
**`#0D0E11`**. See `package.json` (`icon`, `galleryBanner`) for the published values.

## How data maps

- A snippet (`snippets`) has 1..N files in `snippet_files`, ordered by `position`.
- A snippet's primary content is its files in `position` order; `snippets.body` mirrors the first file.
- Only non-deleted rows (`deleted_at is null`) are read.
- Timestamps are epoch-millisecond integers; IDs are app-generated UUID strings.
- On insert, `owner_id` is **not** set — the server supplies it by default.

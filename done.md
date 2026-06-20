# Done — shipped features

The completed counterpart to [spec.md](spec.md). Items here are built, tested
(`flutter analyze` clean, full `flutter test` green, macOS integration flow +
web build passing), and committed. Remaining/planned work stays in `spec.md`.

Effort key matches spec.md (S/M/L). Commits: `7348382` (initial — Snippet look +
multi-file/markdown/modal), `e711905` (P1 batch).

---

## Foundations

- **Snippet green theme + dark sidebar tokens** — `lib/core/theme/app_theme.dart`
  (seed `#16B378`, `sidebar*` palette, green `brandGradient`).
- **Bundled type** — Inter (UI) + JetBrains Mono (code) in `assets/fonts/`,
  pixel-stable incl. PNG/PDF export.
- **Tags → Labels rename** — renamed domain-up (domain, repository API,
  providers, UI, tests); physical SQL stays `tags`/`snippet_tags` (no migration).

## P0 — Local-first Snippet parity ✅ (commit `7348382`)

- **P0.1 Multi-file snippets** — `snippet_files` table (schema **v2**, migration
  backfills one file per existing snippet); `SnippetFile`/`SnippetDraft.files`;
  per-file read/write in `local_snippet_repository.dart`. `Snippet.body`/
  `languageId` kept as a first-file mirror + denormalized FTS body (FTS triggers
  unchanged). Detail renders one `CodeBlock` per file; editor edits N files.
- **P0.2 Filename → auto language** — `lib/core/highlight/language_detect.dart`
  (`detectLanguageFromFilename`); per-file filename field auto-sets language
  unless the user overrides.
- **P0.3 Markdown description** — toolbar in the editor + rendered markdown in the
  detail view via `flutter_markdown_plus`.
- **P0.4 Colored Labels + sidebar** — `LibrarySidebar` (All/Starred/Unlabeled +
  LABELS + LANGUAGES with live counts, click-to-filter, `+` create with color);
  `label_chip.dart` (`labelColor`/`LabelDot`/`LabelChip`); label CRUD in the
  repository; `unlabeled` query filter; `libraryStats` counts.
- **P0.5 Private/Public flag** — `snippets.visibility` (default private);
  `SnippetVisibility`; toggle in the editor, lock/globe pill in detail + cards.
- **P0.6 Dark 3-pane Snippet shell** — `AppShell` (workspace rail + sidebar +
  content), responsive (sidebar → drawer + FAB on narrow), `ShellRoute` routing.
- **P0.7 Copy file contents** — inline copy button in the `CodeBlock` header.
- **Modal editor** — `showSnippetEditor` (`snippet_editor_modal.dart`); NEW
  SNIPPET / Edit open a large (~94%) modal with pinned header/footer so Save is
  always visible; only the form scrolls.

## P1 — Power features ✅

- **P1.1 History / versions** — `snippet_file_versions` table (schema **v3**);
  each save snapshots prior files; detail **History** sheet
  (`snippet_history_sheet.dart`) lists versions with per-file preview +
  **Restore** (itself undoable). Repo: `getVersions`/`restoreVersion`.
- **P1.3 Nested labels** — `tags.parentId` (schema v3); expandable label tree in
  the sidebar + create-with-parent. Repo: `setLabelParent`,
  `createLabel(..., {parentId})`.
- **P1.4 Export HTML / PDF** — `ExportService.exportHtml` (markdown description +
  all files) and `exportPdf` (JetBrains Mono embedded, via `pdf` + `file_saver`,
  no native `printing` plugin); "Save as HTML"/"Save as PDF" menu entries. The
  HTML doubles as the **P1.7** static share page.
- **P1.5 Keyboard shortcuts** — ⌘/Ctrl+N new, ⌘/Ctrl+F focus search, ⌘/Ctrl+S
  save (in editor), Esc closes the modal.
- **P1.2 Attachments** — `attachments` table (schema **v4**); ATTACH in the
  editor (`file_picker`) + a detail Attachments section (image thumbnails, size,
  delete). Repo: `addAttachment`/`deleteAttachment`/`watchAttachments`.
- **P1.6 Gist import** — `lib/features/import/` `GistImporter.fetchGists`
  (public gists by username or URL/ID, optional token; uses `http`) + an import
  dialog (preview → create). Pure `gistsJsonToDrafts` is unit-tested.
- **P1.8 Notebook (.ipynb) rendering** — `lib/core/notebook/ipynb.dart`
  `parseNotebook` (unit-tested) + `NotebookView`; the detail view renders
  `.ipynb` files as cells (markdown + code + outputs).

## P2 — Backend / collaboration

Supabase backend (project `xxxxxxxxxxxxxxxxxxxx`, see [[supabase-project]] memory). App stays **local-first**; sign-in is optional and only turns on sync.

- **P2.1 Accounts** ✅ — `supabase_flutter` + email/password auth (`lib/features/auth/`), optional sign-in/up/out in Settings; `owner_id` set server-side by RLS default. Config in `lib/core/config/supabase_config.dart` (`--dart-define`-overridable).
- **P2.3 Real-time sync (core)** ✅ — `lib/features/sync/data/supabase_sync_service.dart`: push dirty rows (incl. tombstones) + pull-since with last-write-wins, Realtime, debounced `scheduleSync()`; `snippetRepositoryProvider` → `SyncedSnippetRepository`. Pure mappers unit-tested (`test/sync_mapping_test.dart`). Synced: snippets, snippet_files, collections, labels, snippet_labels, ai_prompt_meta (+ workspace_id). **Not synced yet:** attachments (BLOBs) + version history.
- **P2.2 Team libraries** ✅ — schema v5 adds `workspace_id` to all content tables + local `workspaces`/`workspace_members` cache; remote `workspaces`/`workspace_members`/`workspace_invites` with RLS. `WorkspaceService` (online admin, cached locally), `activeWorkspaceProvider` (Personal vs a team) filters the library + stamps new snippets; workspace switcher rail (`app_shell.dart`); content syncs per-workspace.
- **P2.4 Roles** ✅ — `WorkspaceRole` owner/manager/member/viewer; RLS enforces write (viewer = read-only) via SECURITY DEFINER helpers; invite-by-email (`workspace_invites`, auto-accepted on sign-in — no admin/email→uid lookup), member list + role change + remove + leave/delete in `team_screen.dart`.
- **P2.6 VS Code extension** ✅ — `integrations/vscode/` (Sign In / Insert Snippet / Save Selection) on supabase-js; compiles to `out/extension.js`.
- **P2.7 CLI** ✅ — `integrations/cli/` `snip` (login/logout/whoami/list/get/add) on supabase-js; builds via tsc.
- **P2.5 Public share pages** ✅ **deployed** — `supabase/functions/share` is live (`verify_jwt=false`) at `…/functions/v1/share?id=<id>`; the app shows this URL on public snippets. ⚠️ Supabase's shared functions domain forces `text/plain`+`nosniff`+sandbox CSP, so a browser shows the HTML as source — **rendering needs a custom domain** on Edge Functions (see `supabase/README.md`). Export → Save as HTML gives a rendered page today.
- Build note: macOS min deployment target **13.5** (passkeys plugin via `supabase_flutter`); iOS would need 16+ before an iOS build. Live cross-device sync needs a confirmed account (Supabase email-confirmation is on by default). RLS helper functions (`is_member`/`can_write`/`can_manage`) raise a benign advisor WARN (RPC-callable) — they only reveal the caller's own access; revoking would break the policies that use them.

## Bonus (beyond Snippet)

- PNG "carbon" image export; AI-prompt snippet type with `{{variable}}` parsing;
  code editor with find/replace, line numbers, and code folding.

---

## Verification baseline

`flutter analyze` → no issues · `flutter test` → 48 passing · macOS
`integration_test` (list→search→view→copy→delete) → pass · `flutter build web`
→ built · v1→v2 … v4→v5 migrations verified on a real on-disk database ·
macOS app launches with `Supabase init completed` (offline, no session) ·
CLI + VS Code extension compile. macOS min deployment target: 13.5.

# BUILD_PLAN.md — Snippet Manager

Phased, **shippable, incremental** milestones from scaffold to feature-complete. Every phase states a goal, deliverables, key packages, and **how to verify on Web + at least one native target**. Web is a release gate at every phase.

> Global verification rule: each phase must `flutter run -d chrome` (CanvasKit) **and** run on one native target (macOS desktop on this machine, or an Android/iOS device) before being called done.
>
> **Revision note (adversarial review):** the **`screenshot` package was removed** (stale) — off-screen PNG capture now uses framework primitives (off-viewport `OverlayEntry` + `RepaintBoundary.toImage`). **PNG-copy on web is now a best-effort spike, not a promised deliverable** — the guaranteed web PNG path is Save/Share. Drift FTS5 now requires a **`build.yaml` module** entry. Riverpod offline-persistence is **not** used for durability. LWW gets a deterministic tiebreaker.

---

## Phase 0 — Scaffold & runnable on Web
**Goal:** an empty-but-real app that launches on all six targets, with the layered/feature-first skeleton and routing in place.

**Deliverables**
- Flutter 3.44.0 / Dart 3.12.1 project; enable all platforms (`flutter create --platforms=windows,linux,macos,ios,android,web .`).
- Feature-first folder structure (`lib/core`, `lib/features/*/{domain,data,application,presentation}`).
- Riverpod `ProviderScope` at root; `build_runner` wired; one trivial `@riverpod` provider compiles. **Use only `Notifier`/`AsyncNotifier` — no legacy `StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider`.**
- `go_router` with a `ShellRoute` master-detail shell (sidebar + detail pane) and 2–3 placeholder routes; **typed routes** via `go_router_builder`. URLs reflect in the browser address bar.
- `web/index.html` set up for CanvasKit baseline; a documented (commented) COOP/COEP option.
- CI smoke build: `flutter build web` and one native build.

**Key packages:** `flutter_riverpod` 3.3.2, `riverpod_annotation`/`riverpod_generator`, `go_router` 17.3.0, `go_router_builder`, `build_runner`.

**Verify:** `flutter run -d chrome` shows the shell; navigating changes the **browser URL** and is deep-linkable (reload lands on the same screen). Same shell runs on macOS desktop.

---

## Phase 1 — Local storage (Drift) on Web + native
**Goal:** Drift database opens and persists on **web and native**, with the conditional connection correct from day one.

**Deliverables**
- `AppDatabase` (Drift) with a **conditional connection**: `NativeDatabase` (native) / `WasmDatabase` with tiered OPFS→IndexedDB fallback (web).
- **Add `build.yaml` enabling the `fts5` and `json1` drift_dev modules** (needed in Phase 3 to parse the FTS5 DDL; add now so the build config is established):
  ```yaml
  targets:
    $default:
      builders:
        drift_dev:
          options:
            sql:
              dialect: sqlite
              options:
                modules:
                  - fts5
                  - json1
  ```
- Define core tables: `snippets`, `languages`, `collections`, `tags`, `snippet_tags`, `ai_prompt_meta`, `purposes` — **UUIDv7 TEXT PKs, epoch-ms timestamps, `created_at`/`updated_at`/`deleted_at`, reserved `dirty`/`owner_id`**.
- Seed `languages` (python/.py/python, js/.js/javascript, ts, dart, go, rust, sql, json, yaml, markdown, shell, …) and a small `purposes` set.
- Ship `web/sqlite3.wasm` (matching `sqlite3` major) + `web/drift_worker.dart.js` (matching `drift`). Pin in `pubspec.lock`.
- Startup storage-impl detection → warn if web fell back to **in-memory**.
- Migration scaffolding (schema version 1).

**Key packages:** `drift` 2.34.0, `drift_flutter`, `sqlite3_flutter_libs`, `sqlite3`, `drift_dev`, `uuid`.

**Verify:** Insert a row, **reload the browser tab**, row persists (confirms OPFS/IndexedDB, not in-memory). On macOS, the DB file is created and survives app restart. Confirm `sqlite3.wasm`/`drift_worker` versions match (no console errors). **Confirm `build_runner` generates without errors** (proves the `build.yaml` module config is valid before Phase 3 needs it).

---

## Phase 2 — Core CRUD + categorization
**Goal:** create, read, update, soft-delete snippets; assign language, type, purpose, collection, tags.

**Deliverables**
- Domain `Snippet` entity + `SnippetRepository` **interface** (CRUD + reactive list `Stream`s) — pure Dart, no Drift types.
- `LocalSnippetRepository` (Drift) mapping rows ⇄ entities; exposes Drift `watch` streams. Wired behind a **single Riverpod provider**.
- Riverpod `AsyncNotifier`s for list + editor state.
- UI: snippet list (master), detail view (read-only via `re_highlight` `SelectableText.rich`), editor (via `re_editor`) with pickers for type (code/ai_prompt/text), language, purpose, collection, tags.
- Collections tree (nestable) + free-form tags (M:N) management.
- `ai_prompt_meta` editor for `type='ai_prompt'`, including `{{variable}}` parsing into the variables JSON.
- **Soft delete** (`deleted_at`) only; lists filter `deleted_at IS NULL`.

**Key packages:** `re_highlight` 0.0.3 (display), `re_editor` 0.9.0 (edit), `uuid`, Drift/Riverpod from prior phases.

**Verify:** Create a Python snippet on web, edit it, soft-delete it; it disappears from the list and survives reload. Create an AI prompt with `{{name}}` → variable is captured. Repeat on macOS. Highlighting renders correctly on both.

---

## Phase 3 — Search (FTS5 + filters)
**Goal:** fast full-text search + filter chips working identically on web and native.

**Deliverables**
- `snippets_fts` external-content FTS5 virtual table declared in a **`.drift` file** (relies on the Phase-1 `build.yaml` `fts5` module so `drift_dev` parses the DDL); triggers on `snippets` and `snippet_tags` (re-denormalize `tag_text`).
- Repository `search(query, filters, sort)` method returning a reactive stream; bm25 rank (title-boosted) when text present, recency when not.
- Debounced (~150ms) search box; prefix queries (`term*`).
- Filter chips: Type, Language (multi), Collection tree, Tags (multi + AND/OR), Favorites. Sort: Recent / Created / Title / Relevance.

**Key packages:** `drift` (FTS5 via bundled/wasm sqlite3 — no extra runtime package; `build.yaml` module is build-time only), Riverpod.

**Verify:** Type a partial term on web → matching snippets appear as-you-type; add a tag filter → results narrow; reload preserves data. Confirm tag-text search updates after editing tags (triggers fire). **Confirm FTS5 runs on web specifically (bundled `sqlite3.wasm` has FTS5).** Same on macOS.

---

## Phase 4 — Copy + file export (text + source file)
**Goal:** copy to clipboard and export as `.txt` / source-file-with-correct-extension on all targets.

**Deliverables**
- `ExportService` interface + `SnippetExportData` value object (depends only on snippet content + `languages.file_extension`).
- **Copy-as-plain-text** via `super_clipboard`, with built-in `Clipboard.setData` as the **guaranteed text-only fallback**; **copy-as-HTML** via `super_clipboard` (degrades to text on Firefox).
- "Save as source file" → `file_saver.saveFile(bytes, fileExtension from language, mimeType)`; "Save as .txt" likewise.
- Export bytes built as `Uint8List` in a platform-agnostic layer (reused later for share + PNG).

**Key packages:** `super_clipboard` 0.9.1, `file_saver` 0.4.0.

**Verify:** On web, "Save as source file" for a JS snippet downloads `snippet.js`; copy → paste into an editor yields the code. On macOS, the file lands on disk / via dialog and clipboard paste works. Verify **text selection + text-copy** specifically on web (canvas-rendered) — this is the only guaranteed web clipboard write.

---

## Phase 5 — PNG export (carbon-style) + share sheet
**Goal:** export a syntax-highlighted, themed PNG of a snippet; share text/file/PNG via the OS share sheet. **The guaranteed web PNG path is Save + Share; PNG-copy on web is a spike, not a commitment.**

**Deliverables**
- Carbon-style export card widget: gradient/solid background, padded rounded window, 3 traffic-light dots, `re_highlight` `TextSpan` body, optional **text/vector** watermark.
  - **HARD RULE + test:** the card contains **no raster `Image`/`DecorationImage` texture**. Add a widget test that walks the card's element tree and **fails** if a raster `Image` widget is present (guards against future export-theme regressions that would break web `toImage` silently).
- **Off-screen capture via framework primitives (no `screenshot` package):** mount the card in an **`OverlayEntry` positioned off the visible viewport**, wrapped in `RepaintBoundary` with a `GlobalKey`; after one frame, call `boundary.toImage(pixelRatio: 3.0)` → `toByteData(ImageByteFormat.png)`; remove the entry. On-screen path uses the same `RepaintBoundary`+`toImage`.
- Persist PNG via **`file_saver`** (guaranteed on web); **share** PNG/source-file/text via `share_plus` (`SharePlus.instance.share(ShareParams(files:[XFile.fromData(...)], sharePositionOrigin))`).
- **Spike (gate before any "Copy PNG" UI ships):** prototype `super_clipboard` programmatic **image** write on web behind a **synchronous** user gesture, on **Chrome AND Safari**. If it works, expose "Copy image" on those browsers; **if not, the web UI shows "Save image" instead** (no broken/missing-clipboard promise). Native copy-PNG proceeds normally (Android: NDK + minSdk 23 + content provider in manifest).
- Wire share **directly to button `onTap`, before any `await`** (web transient user-activation); feature-detect web share, fall back to download. Pass `sharePositionOrigin` for iPad.

**Key packages:** `file_saver` 0.4.0, `super_clipboard` 0.9.1 (text guaranteed; image best-effort), `share_plus` 13.1.0, `cross_file`. *(`screenshot` removed.)*

**Verify:**
- On web (CanvasKit), export PNG via Save → downloads a crisp 3x image with highlighted code (card is text+vector, so it renders correctly).
- On macOS, PNG saves and the share sheet opens with the image.
- **Run the PNG-copy spike on Chrome AND Safari**; record the result and ensure the web UI degrades to "Save image" wherever copy fails (and on Firefox).
- **Visual-diff the PNG across CanvasKit web, a `flutter build web --wasm`/skwasm build, and macOS** to catch any theme/`toImage` regression (confirms `toImage` works under skwasm and that no raster slipped in).

---

## Phase 6 — Polish & theming
**Goal:** production-quality UX across form factors and platforms.

**Deliverables**
- Light/dark app themes + selectable **export themes** for the PNG card (each must still satisfy the no-raster-Image rule + pass the card test).
- Responsive master-detail (collapse to single-pane on narrow/mobile); keyboard shortcuts on desktop/web (copy, new, search focus).
- Empty/loading/error states; favorites; manual sort (`sort_index`).
- Web-specific QA: text selection/copy, deep-link reloads, storage-fallback warning banner.
- Settings screen (theme, default language, default export format/theme).
- Optional `--wasm` build pipeline + documented COOP/COEP host config.

**Key packages:** existing stack.

**Verify:** Resize the browser window → layout adapts; deep-link to a snippet URL and reload → lands correctly; dark mode + each export theme produce correct PNGs on **web (CanvasKit + `--wasm`)** and macOS (re-run the visual diff for new themes).

---

## Phase 7 — Sync (designed, deferred) — additive, no rewrite
**Goal:** keep the codebase sync-ready and stub the seam; do **not** build the cloud yet.

**Deliverables**
- Confirm Repository returns only domain entities/streams (audit: no Drift/Supabase types leak to UI/state).
- Define (unused-yet) `RemoteSnippetDataSource` + `SyncEngine` interfaces and a `SyncedSnippetRepository` shell that wraps Local; leave the Riverpod provider pointing at Local.
- Document the Supabase plan: 1:1 Postgres mirror; RLS on every table with `(select auth.uid()) = owner_id`; **Drift-backed** outbox table + watermark pull; **LWW on `updated_at` with a deterministic tiebreaker (then `opId`/`owner_id`)** + `lastSyncedHash` conflict-copy; `shared_snippets` token table + `SECURITY DEFINER` RPC for share-by-link.
- **Explicitly keep Riverpod 3's experimental offline-persistence OUT of the durability path** — the Drift outbox is the source of truth for un-synced ops.
- Decide build-vs-buy later: hand-rolled outbox vs `powersync`. **Re-verify `supabase_flutter`'s exact current version at adoption time** (do not pin now).

**Key packages (future):** `supabase_flutter` (verify version at adoption), optionally `powersync`.

**Verify:** App still runs fully **offline/local** on web + native (sync is inert). Static check confirms swapping the repository provider is the only change needed to introduce remote — proving the no-rewrite design.
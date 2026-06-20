# ARCHITECTURE.md — Snippet Manager

A cross-platform (Windows, Linux, macOS, iOS, Android, **Web**) snippet and AI-prompt manager built in Flutter. **Local-first** today, **sync-ready** for Supabase Postgres tomorrow — designed so cloud sync attaches without a rewrite. Web is a **first-class** target: every choice below is verified to work on Flutter Web.

> Verified versions as of **2026-06-19**. Pin exact versions in `pubspec.lock` and re-verify on upgrade (especially the Drift web WASM artifacts).
>
> **Adversarial-review corrections applied (this revision):**
> 1. **`super_clipboard` web PNG-copy demoted** from "works" to **unverified / best-effort** — its docs only affirmatively document *text-only* web writes (copy/cut handlers, Firefox); programmatic image-copy on web is unconfirmed for **all** browsers. The guaranteed web path for the PNG is **Save (`file_saver`)** / **Share (`share_plus`)**.
> 2. **`screenshot` package dropped as the primary off-screen capture path** — it is **stale (3.0.0, published ~2 years ago, requires Flutter ≥3.22)** and predates the CanvasKit-default/skwasm renderer landscape. Off-screen capture now uses **framework primitives** (off-viewport `OverlayEntry` + `RepaintBoundary` + `toImage`) — identical renderer behavior to the on-screen path, no third-party dependency.
> 3. **Drift FTS5 build config added** — `drift_dev` needs the `fts5`/`json1` modules enabled in `build.yaml` to *parse* `CREATE VIRTUAL TABLE … USING fts5` in `.drift` files.
> 4. **"No raster `Image` in the export card" promoted from guideline to a hard, test-asserted rule** (the CanvasKit `toImage` raster bug is real: flutter#106314).
> 5. **Riverpod 3 offline-persistence marked experimental** and kept **out of the sync durability path** (the Drift outbox owns durability).
> 6. **Deterministic LWW tiebreaker** added (`updated_at`, then `opId`/`owner_id`) for same-millisecond conflicts.

---

## 1. Tech Stack

| Concern | Package | Version | Web? | Why |
|---|---|---|---|---|
| UI toolkit | `flutter` (SDK) | 3.44.0 (stable, 2026-05-18) | ✅ | One codebase, six targets; desktop stable since 3.0 (Canonical-stewarded). |
| Language | Dart SDK | 3.12.1 (stable, 2026-05-26) | ✅ | JS + WasmGC compile targets. |
| State + DI | `flutter_riverpod` | 3.3.2 | ✅ (pure Dart) | BuildContext-independent repository injection; compile-safe codegen; v3 adds auto-retry w/ backoff + **(experimental)** offline persistence. |
| State codegen | `riverpod_annotation` | 3.3.2 | ✅ (pure Dart) | `@riverpod` typed providers. |
| State codegen (dev) | `riverpod_generator` + `build_runner` | 3.3.2 | dev-only | Generates providers. |
| Routing | `go_router` | 17.3.0 | ✅ | Official router; ShellRoute master-detail; **deep-linkable browser URLs**. |
| Routing codegen (dev) | `go_router_builder` | tracks 17.x | dev-only | Typed, refactor-safe routes. |
| Local DB | `drift` | 2.34.0 | ✅ (sqlite3.wasm) | Only candidate with web + FTS5 + relational/typed model; schema maps 1:1 to Supabase Postgres. |
| DB Flutter glue | `drift_flutter` | current | ✅ | Opens native file via `path_provider`; opens WASM DB on web with sane defaults. |
| Native SQLite | `sqlite3_flutter_libs` | current | native-only | Bundles native sqlite3 with FTS5 + json1. |
| SQLite engine/bindings | `sqlite3` | current 2.x | ✅ | Provides `sqlite3.wasm` web asset (FTS5 + json1 enabled). |
| DB codegen (dev) | `drift_dev` + `build_runner` | current | dev-only | Typed tables/DAOs; FTS5 in `.drift` files — **requires `modules: [fts5, json1]` in `build.yaml`** (see §4). |
| IDs | `uuid` | current (v7 capable) | ✅ | Client-side **UUIDv7** PKs — time-ordered, collision-free offline. |
| Highlight (display) | `re_highlight` | 0.0.3 (early version number; broad coverage, active) | ✅ | highlight.js grammars → `TextSpan`; standalone; powers read view AND the PNG card. |
| Code editor (edit) | `re_editor` | 0.9.0 (active, reqable.com) | ✅ | In-app editing built on `re_highlight`. |
| **Off-screen capture** | **(none — framework primitives)** | n/a | ✅ | **No third-party package.** Mount the card in an off-viewport `OverlayEntry` (so it is truly painted, avoiding the `Offstage` `!debugNeedsPaint` assertion), then `RepaintBoundary.toImage(pixelRatio: 3.0)`. Identical renderer behavior to the on-screen path; fully under our control. *(See §6.)* |
| Save bytes | `file_saver` | 0.4.0 | ✅ (Blob download) | Source-file (`.py`/`.js`/…), `.txt`, and PNG export from `Uint8List`. **The guaranteed universal web export path.** |
| Rich clipboard | `super_clipboard` | 0.9.1 | ✅ **for text/HTML**; ⚠️ **PNG-copy unverified on web** | Copy code as text/HTML across platforms. **PNG-copy is native-first; on web it is best-effort and must be proven in the Phase-5 spike (see §6).** |
| OS share sheet | `share_plus` | 13.1.0 | ✅ (Web Share API + download fallback) | Share text + files/XFile across platforms. |
| File wrapper | `cross_file` (XFile) | via share_plus | ✅ | Bytes-based XFile (no real path needed on web). |
| **Future** remote/auth | `supabase_flutter` | re-verify at adoption (~2.x) | ✅ | RemoteDataSource + auth + Realtime when sync ships (deferred). |
| **Future, optional** sync | `powersync` | evaluate at adoption | ✅ (verify maturity) | Managed Supabase↔SQLite alternative to hand-rolled outbox. |

**Fallback highlighters (only if `re_highlight` lacks a grammar):** `flutter_highlighting` 0.9.0 (190+ languages, ~3yr stale) or `syntax_highlight` (serverpod, TextMate, ~15 curated languages). **Rejected:** `flutter_highlight`/`highlight` (frozen ~5yr), `flutter_code_editor` (no Web on pub.dev), **`screenshot`** (stale 3.0.0 ~2yr; replaced by framework primitives — see correction #2 above).

> **Staleness watchlist (same treatment as the fallback highlighters):** `re_highlight` carries a `0.0.x` version number; `screenshot` 3.0.0 is ~2 years untouched and **not used**. Re-verify these on every dependency review.

---

## 2. High-Level Architecture

**Feature-first** folders with **clean layering**. Dependencies point inward: UI → State → Domain ← Data. The **Domain Repository interface is the seam** that makes cloud sync additive.

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION (UI)   widgets, screens, go_router ShellRoute    │
│   - master-detail layout, list, editor, export dialog         │
│   - watches Riverpod providers; never knows about Drift/cloud │
├─────────────────────────────────────────────────────────────┤
│ APPLICATION (STATE) Riverpod Notifier/AsyncNotifier (codegen) │
│   - holds UI state, debounced search, filter state            │
│   - calls Repository; exposes reactive streams to UI          │
├─────────────────────────────────────────────────────────────┤
│ DOMAIN (pure Dart)  Entities + Repository INTERFACES          │
│   - Snippet, Language, Collection, Tag, AiPromptMeta (plain)  │
│   - abstract SnippetRepository (CRUD + search/filter streams) │
│   - NO Drift/Supabase types leak here                         │
├─────────────────────────────────────────────────────────────┤
│ DATA (repositories) LocalSnippetRepository (Drift) — today    │
│   - maps Drift rows ⇄ domain entities                         │
│   - [LATER] SyncedSnippetRepository wraps Local + Remote      │
├─────────────────────────────────────────────────────────────┤
│ DATASOURCE          LocalDataSource = Drift (sqlite3 / wasm)  │
│   - [LATER] RemoteDataSource = supabase_flutter + SyncEngine  │
└─────────────────────────────────────────────────────────────┘
```

**Key rules**
- The Repository returns **domain entities and reactive `Stream`s** (Drift's `watch`), never Drift-generated rows or Supabase types. This is what keeps the storage backend swappable.
- A **single Riverpod provider** supplies the active `SnippetRepository`. Swapping `LocalSnippetRepository` for a `SyncedSnippetRepository` later changes one provider, not the UI or business logic.
- **Riverpod 3 note:** start on `Notifier`/`AsyncNotifier` (codegen). `StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider` are **legacy** in v3 — avoid to prevent migration debt. **Riverpod 3 offline-persistence is EXPERIMENTAL — do NOT use it for sync durability;** the Drift outbox table (§7) owns durability.
- **Web rendering:** ship default **CanvasKit** as the baseline build, plus a separate `flutter build web --wasm` build (auto-selects skwasm where WasmGC is available, falls back to CanvasKit). Serve **COOP/COEP** headers as an *optimization*; treat WASM as progressive enhancement, never the only build (open Safari/Chrome WasmGC bugs in 2026).

---

## 3. Sync-Ready Data Model

SQLite (Drift) locally; the **same relational shape** deploys to Supabase Postgres later. **All PKs are `TEXT` UUIDv7** (client-generated). **All timestamps are `INTEGER` epoch-millis UTC.** Every syncable row carries `created_at`, `updated_at`, `deleted_at` (soft-delete tombstone), and (reserved) `dirty` / `owner_id`.

### Why these choices (non-negotiable from v1)
- **UUIDv7 PKs, never autoincrement.** Two offline devices both minting `id=5` cannot merge. UUIDv7 is time-ordered → good local B-tree index locality + globally unique → safe sync. Maps to Postgres native `uuid`. **Retrofitting PKs after users have data is the "rewrite" we are avoiding.**
- **`updated_at` everywhere** → enables row-level **Last-Write-Wins** merge later. **LWW must use a deterministic tiebreaker** (see §7.3): compare `updated_at` first, then break ties on `opId` (or `owner_id`) so two edits within the **same millisecond** resolve identically on every device.
- **Soft delete (`deleted_at`), never hard `DELETE`.** A hard delete cannot propagate — another device just re-uploads the row. Tombstones travel with the row and let share-links detect revocation.
- **`dirty` / `owner_id` reserved now** (nullable) so they can be populated later without a migration.

### Entities

**`snippets`** (single polymorphic table, `type` discriminator)
| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | UUIDv7 |
| `title` | TEXT NOT NULL | |
| `body` | TEXT NOT NULL | the code / prompt / text (single source of truth) |
| `type` | TEXT NOT NULL | CHECK in (`code`,`ai_prompt`,`text`) |
| `language_id` | TEXT NULL FK→languages | nullable (plain text/prompts may have none) |
| `purpose` | TEXT NULL | slug → `purposes` lookup |
| `description` | TEXT NULL | |
| `collection_id` | TEXT NULL FK→collections | a snippet lives in 0..1 folder |
| `is_favorite` | INTEGER NOT NULL DEFAULT 0 | bool |
| `sort_index` | INTEGER NULL | optional manual ordering |
| `created_at` / `updated_at` | INTEGER NOT NULL | epoch-ms UTC |
| `deleted_at` | INTEGER NULL | tombstone |

Indexes: `(type)`, `(language_id)`, `(collection_id)`, `(is_favorite)`, `(updated_at DESC)`, `(deleted_at)`.

**`languages`** (seeded reference, user-extendable) — the **language → extension → grammar** map
`id` (slug, e.g. `python`), `name` (`Python`), `file_extension` (`.py`), `grammar_id` (highlighter id, `python`), `aliases` (JSON `["py","python3"]`). Seed from the highlighter's language list. For `type='ai_prompt'`, convention is grammar `markdown`/`plaintext`, extension `.md`/`.txt`.

**`collections`** (folders, self-nestable)
`id` PK, `name`, `parent_id` NULL FK→collections (self-ref), `icon`/`color` NULL, `created_at`/`updated_at`/`deleted_at`. Single home per snippet via `snippets.collection_id` (tags handle cross-cutting many-to-many). A snippet↔collection M:N join is deferred but easy because schema is normalized.

**`tags`** (free-form)
`id` PK, `name`, `normalized_name` (lowercased), `color` NULL, timestamps + `deleted_at`. `UNIQUE(normalized_name) WHERE deleted_at IS NULL`.

**`snippet_tags`** (M:N join)
`PK(snippet_id, tag_id)`, `created_at`. Index on `tag_id` for reverse lookup. **True many-to-many** independent of the single-folder collection.

**`ai_prompt_meta`** (1:1 extension; row exists only when `type='ai_prompt'`)
`snippet_id` PK FK→snippets (shared PK enforces 1:1), `target_model`, `model_provider`, `system_prompt`, `temperature`, `max_tokens`, `variables` (JSON), `updated_at`.

**`purposes`** (small seeded lookup, extensible) — `id` slug (`utility`,`boilerplate`,`algorithm`,`regex`,`sql-query`,`summarization-prompt`,…), `label`, `applies_to_type` NULL/csv. Orthogonal to language and type.

**Prompt variables:** store `{{variable}}` tokens in `snippets.body` (single source of truth); parse them at save time into `ai_prompt_meta.variables` JSON (`{name,label,default,required,description}`) to drive a fill-in form on copy/export.

### Relationships (summary)
- `snippets.language_id → languages.id` (N:1, optional)
- `snippets.collection_id → collections.id` (N:1, optional); `collections.parent_id → collections.id` (tree)
- `snippets ↔ tags` via `snippet_tags` (M:N)
- `snippets ⇄ ai_prompt_meta` (1:1, prompt-only)
- `snippets.purpose → purposes.id` (N:1, optional)

---

## 4. Search

**SQLite FTS5** — in the default build for both native (`sqlite3_flutter_libs`) and web (`sqlite3.wasm`), so the **same query runs everywhere, no platform branching.** *Verified:* the prebuilt `sqlite3.wasm` ships with **FTS5 + json1 enabled**, so full-text search genuinely works on Flutter Web.

> **Build-time requirement (verified, was missing):** FTS5 being available **at runtime** is necessary but not sufficient. `drift_dev` must also be told to enable the `fts5` (and `json1`) **modules for static analysis**, or the generator will **fail to parse** the `CREATE VIRTUAL TABLE … USING fts5` DDL in the `.drift` file. Add to **`build.yaml`** (per the official Drift generation-options docs):
>
> ```yaml
> targets:
>   $default:
>     builders:
>       drift_dev:
>         options:
>           sql:
>             dialect: sqlite
>             options:
>               modules:
>                 - fts5
>                 - json1
> ```
>
> This affects the analyzer only; runtime FTS5 still comes from the bundled native lib / `sqlite3.wasm` (both have it).

External-content FTS5 virtual table (declared in a **`.drift` file** — FTS5 cannot be declared in Dart):

```sql
CREATE VIRTUAL TABLE snippets_fts USING fts5(
  title, body, description, tag_text,
  content='snippets', content_rowid='rowid',
  tokenize='unicode61 remove_diacritics 2');
```

- Kept in sync via **AFTER INSERT/UPDATE/DELETE triggers** on `snippets`, plus triggers on `snippet_tags` to re-denormalize `tag_text` (space-joined tag names). *Forgetting the `snippet_tags` triggers silently makes tag search stale.*
- Query joins FTS rank with `WHERE` filters:

```sql
SELECT s.* FROM snippets_fts f
JOIN snippets s ON s.rowid = f.rowid
WHERE snippets_fts MATCH :query
  AND s.deleted_at IS NULL
  AND (:type IS NULL OR s.type = :type)
  AND (:language_id IS NULL OR s.language_id = :language_id)
  AND (:collection_id IS NULL OR s.collection_id = :collection_id)
  AND (:favorite_only = 0 OR s.is_favorite = 1)
ORDER BY rank;            -- bm25; boost title over body
```

- **Empty-query browsing** (filters only) bypasses FTS and queries `snippets` directly `ORDER BY updated_at DESC`.
- As-you-type uses **prefix queries** (`term*`), debounced ~150ms.
- **WAL is unsupported on web** — irrelevant to FTS5 (matters only for raw `.db` file import); noted here for completeness.
- The **FTS index is local-only** — do NOT sync it to Supabase. On sync it becomes Postgres `tsvector` + GIN, hidden behind the same Repository search method.

**Search/Filter UX:** persistent debounced search box; filter chips for Type / Language / Collection (folder tree) / Tags (multi-select with AND/OR) / Favorites; sort by Recent (default) / Created / Title A–Z / Relevance (only when a text query is active).

---

## 5. Syntax Highlighting

- **Display:** `re_highlight` (highlight.js grammars → `TextSpan`) rendered in `SelectableText.rich`. Lightweight — used in the list, detail view, **and the PNG card**.
- **Editing:** `re_editor` (folding, find/replace, line numbers) only on the edit screen. **Do not** use `re_editor` as a read-only viewer everywhere — it hurts list/scroll perf.
- `languages.grammar_id` maps each language to a highlight grammar; unknown grammars **fall back to plaintext** so the UI never crashes.
- Broaden coverage with `flutter_highlighting` (190+ langs) only if a needed grammar is missing.

---

## 6. Export / Share Pipeline

One **`ExportService`** behind a platform-agnostic interface. It depends only on a `SnippetExportData` value object (title, body, language extension, theme) — **not** on the storage or sync layer, so the identical code runs on Web. Build the PNG and source-file bytes as `Uint8List` in a platform-agnostic layer, then hand the **same bytes** to save / copy / share.

| Operation | Mechanism | Web behavior | Native behavior |
|---|---|---|---|
| **Copy as plain text** | `super_clipboard` (text); built-in `Clipboard.setData` fallback | ✅ Async Clipboard API (text) — **the only guaranteed web clipboard write** | OS clipboard |
| **Copy code as HTML** | `super_clipboard` (HTML) | ✅ (Firefox copy/cut handlers are text-only; HTML may degrade to text) | OS clipboard |
| **Copy rendered PNG** | `super_clipboard` (PNG image) | ⚠️ **UNVERIFIED / best-effort on ALL browsers** — *not a promised feature*. Must be proven in the Phase-5 spike behind a real user gesture on **Chrome AND Safari**; otherwise the web UI offers **"Save image"** instead. | ✅ OS clipboard (Android: needs NDK + minSdk 23 + content-provider in manifest) |
| **Save as source file** (`.py`/`.js`/`.ts`/…) | `file_saver.saveFile(bytes, fileExtension, mimeType)` | ✅ Blob **download** (no real path) — **guaranteed universal web path** | Save to default dir; `saveAs()` dialog (not Linux) |
| **Save as `.txt`** | `file_saver` | ✅ Blob download | file write / dialog |
| **Save PNG** | `file_saver` | ✅ Blob download — **guaranteed universal web path for the PNG** | file write / dialog |
| **Share to other apps** | `share_plus` `SharePlus.instance.share(ShareParams(...))` | ✅ Web Share API (HTTPS + **synchronous** user-gesture) with **download fallback** | OS share sheet (files: not Linux — Linux is text-only) |

- **Why the PNG-copy demotion (corrected this revision):** `super_clipboard`'s docs only affirmatively document **text-only** web writes (the copy/cut event handlers, which on Firefox cannot carry images and cannot provide data asynchronously). They do **not** confirm a working programmatic image-write web code path for Chrome/Safari either — they merely recommend "use the regular clipboard API when `SystemClipboard.instance` is non-null on web." The browser Async Clipboard API *can* write `image/png` on Chromium 76+, but that is a **browser** capability, not a **verified `super_clipboard` web path**. Therefore: **PNG-copy on web is best-effort, gated behind a Phase-5 spike, and never the only way to get the PNG out of the app on web.**
- **Plain-text fallback:** Flutter's built-in `Clipboard.setData` is kept as the trivial, **guaranteed** text fallback; it **cannot** put a PNG on the clipboard.
- **Reliable universal web path** for getting bytes out is **Save (`file_saver` download)**; **Share** is best-effort (feature-detect via `navigator.canShare`); **PNG-copy** is best-effort (Phase-5 spike).

### Code → PNG (carbon.now.sh-style)

The export card is a **pure-Flutter widget**: `Container` (gradient/solid background, padding) → rounded "window" with 3 traffic-light dots → `RichText`/`SelectableText.rich` built from `re_highlight`'s `TextSpan` → optional watermark **as text/vector** (not a raster `Image`).

**HARD RULE (was a guideline): no raster `Image`/`DecorationImage` raster texture/logo anywhere in the export card.** This is enforced in code review **and asserted by a widget test** that walks the card's element tree and fails if a raster `Image` is present. Rationale: the CanvasKit `RenderRepaintBoundary.toImage` bug (flutter#106314 / #103612 / #115822) silently drops embedded **raster** images from web captures; a text+vector-only card sidesteps it, but a future export theme that sneaks in a raster asset would **silently regress only on web**.

Capture (framework primitives only — **no `screenshot` package**):
- **On-screen:** `RepaintBoundary` + `GlobalKey` → `boundary.toImage(pixelRatio: 3.0)` → `toByteData(format: ImageByteFormat.png)`.
- **Off-screen (export without showing the card):** mount the card inside an **`OverlayEntry`** positioned **off the visible viewport** (e.g. far negative offset) wrapped in a `RepaintBoundary` with a `GlobalKey`. Because it is inserted into the real overlay, it is **actually laid out and painted** (avoiding the `Offstage` `!debugNeedsPaint` assertion that breaks naive offscreen capture, flutter#40064). After one frame (`addPostFrameCallback` / `endOfFrame`), call `boundary.toImage(pixelRatio: 3.0)`, then remove the `OverlayEntry`. This is exactly what the old `screenshot.captureFromWidget` did internally — but with **identical renderer behavior to our on-screen path, no stale third-party dependency, and full control.**

**Why this works on Web:** the old HTML renderer (which threw on `toImage`) has been **removed**; current Flutter ships **CanvasKit** (default) and **skwasm** (WASM mode) — both implement `RenderRepaintBoundary.toImage`, so PNG export works on web with **no `--web-renderer` flag**. Because the card is **text + vector only**, it sidesteps the CanvasKit `toImage` raster-image bug. Set `pixelRatio` explicitly (≈3.0) for crisp high-DPI output. Persist the resulting `Uint8List` with `file_saver`.

> **Residual risk (documented, not blocking):** `toImage` anti-aliasing/sub-pixel output on web can differ subtly from native (flutter#165380), so pixel-exact web↔native parity is **not guaranteed** even with text+vector. Phase 5 includes a visual diff across CanvasKit web, a `--wasm`/skwasm build, and macOS.

---

## 7. How Cloud Sync (Supabase) Attaches Later — No Rewrite

The seam is already in place; sync is **purely additive**.

1. **Add a `RemoteSnippetDataSource`** (`supabase_flutter` — six-platform incl. Web; **re-verify exact current version at adoption time**) and a `SyncEngine`. Introduce a `SyncedSnippetRepository` that wraps the existing `LocalSnippetRepository` + remote, and **point the single Riverpod repository provider at it**. UI/state untouched — they still watch the same domain `Stream`s.
2. **Mirror the local schema 1:1 in Postgres** (`TEXT`→`uuid`, `INTEGER` epoch→`timestamptz`, JSON→`jsonb`). FTS5 → `tsvector` + GIN. Already-present `owner_id uuid references auth.users` populated at sync time.
3. **Conflict resolution = row-level Last-Write-Wins with a deterministic tiebreaker.** Compare `updated_at`; **on a same-millisecond tie, break deterministically on `opId` (then `owner_id`)** so every device converges to the same winner. (Epoch-**milliseconds** can tie under concurrent edits; without the tiebreaker LWW is non-deterministic.) Snippets are single-author, rarely edited concurrently → LWW is the right pragmatic call; **CRDTs rejected** as over-engineered for single-author text. Cheap insurance: keep a `lastSyncedHash` to detect true conflicts and stash the losing version as a "conflict copy" snippet rather than discarding.
4. **Outbox / dirty-flag (the durability path — NOT Riverpod persistence):** every local mutation sets `dirty=true` and enqueues a **Drift-backed** outbox row (`opId` UUID, entityId, op, payload, createdAt). The SyncEngine drains the outbox to Supabase using the **row/op UUID as an idempotency key** (upsert-on-id), clears `dirty` on ack. Pull side uses a **watermark** (`WHERE updated_at > lastSync`). Realtime can later make the pull event-driven. *(Riverpod 3's experimental offline-persistence is explicitly **not** used here.)*
5. **Security (launch gate when sync ships):** enable **RLS on every table** with policies written as `(select auth.uid()) = owner_id` (the `select`-wrapper is the documented perf form — initPlan caching; bare `auth.uid()` re-evaluates per row). RLS-off is a known foot-gun (CVE-2025-48757).
6. **Share-by-link:** a separate `shared_snippets` table (`token` random UUID, `snippet_id`, `owner_id`, `created_at`, `expires_at` nullable, `revoked` bool). Anon read goes through a `SECURITY DEFINER` RPC `get_shared_snippet(token)` — the main `snippets` table is **never** made public, so a leaked policy can't expose a user's whole library. Link = `app.url/s/<token>`; revoke by flag.
7. **Build-vs-buy deferred:** hand-rolled outbox vs `powersync`. The UUID+timestamps+tombstone schema keeps both doors open.

---

## 8. Project Folder Structure (feature-first)

```
lib/
  core/                        # cross-cutting
    db/                        # AppDatabase (Drift), conditional connection (native vs web)
    routing/                   # go_router config, ShellRoute, typed routes
    theme/                     # themes incl. carbon export themes
    utils/                     # uuid v7, time helpers
  features/
    snippets/
      domain/                  # Snippet entity, SnippetRepository (interface)
      data/                    # LocalSnippetRepository (Drift) [+ Synced... later]
      application/             # Riverpod Notifiers/AsyncNotifiers
      presentation/            # list, detail, editor screens/widgets
    search/
      domain/ application/ presentation/
    categorization/            # languages, collections, tags, purposes
      domain/ data/ application/ presentation/
    export/
      domain/                  # ExportService interface, SnippetExportData
      data/                    # file_saver / super_clipboard / share_plus impls
      presentation/            # carbon PNG card widget, OverlayEntry capture, export dialog
    settings/
      ...
  main.dart
web/
  index.html                   # CanvasKit baseline; COOP/COEP optional
  sqlite3.wasm                 # MATCH sqlite3 package major version
  drift_worker.dart.js         # MATCH drift version
build.yaml                     # drift_dev: enable fts5 + json1 modules (see §4)
```

The Drift `AppDatabase` uses a **conditional connection** from day one: `NativeDatabase` on native, `WasmDatabase` (tiered OPFS→IndexedDB fallback) on web — otherwise web persistence silently fails.

---

## 9. Platform-Specific Caveats (especially Flutter Web)

| Area | Caveat | Action |
|---|---|---|
| **Web build** | Plain `flutter build web` is CanvasKit-only; `--wasm` adds skwasm (needs WasmGC; falls back to CanvasKit). | Ship CanvasKit as baseline; `--wasm` as progressive enhancement. |
| **Web COOP/COEP** | skwasm worker threads + Drift OPFS + SharedArrayBuffer need `Cross-Origin-Opener-Policy: same-origin` + `Cross-Origin-Embedder-Policy: require-corp`. | Set on host/CDN. Without them: skwasm single-threaded; **Drift falls back through tiered storage (opfsShared [Firefox] → opfsLocks [needs COOP/COEP] → sharedIndexedDb → unsafeIndexedDb → in-memory, data lost on reload)** — detect storage impl at startup and warn. |
| **Web WASM bugs (2026)** | Safari WasmGC bug; flutter #184843 blank screen on Chrome 146 when `crossOriginIsolated`. | Keep CanvasKit baseline; test the COOP/COEP path. |
| **Drift web assets** | Must ship `web/sqlite3.wasm` (matching sqlite3 major) + `web/drift_worker.dart.js` (matching drift). Mismatch = runtime failure. | Re-download matching artifacts on every Drift/sqlite3 upgrade; keep in lockstep with `pubspec.lock`. |
| **Drift FTS5 codegen** | `drift_dev` cannot parse `CREATE VIRTUAL TABLE … USING fts5` unless the `fts5` module is enabled in `build.yaml`. | Add `modules: [fts5, json1]` under `drift_dev > options > sql > options` (see §4). |
| **Drift web limits** | WAL unsupported on web (irrelevant to FTS5; matters for raw `.db` import). Safari "Good" (reduced) support; OPFS-shared-worker is Firefox-only. | Test the IndexedDB fallback explicitly on Safari/iOS-web. |
| **Web text/clipboard** | Canvas-rendered text selection/copy differs subtly from native HTML; **only text writes are guaranteed** via the clipboard. | Verify text selection + text-copy on web. **PNG-copy is best-effort (Phase-5 spike); web offers "Save image" as the guaranteed alternative.** |
| **PNG export (web)** | `toImage` works on CanvasKit & skwasm; embedded **raster** images can be missing (flutter#106314). | Card = text + vector only (**hard rule, test-asserted**); persist via `file_saver`. Set `pixelRatio≈3.0`. **No `screenshot` package** — use off-viewport `OverlayEntry` + `RepaintBoundary.toImage`. |
| **Offscreen capture** | Naive `Offstage` + `RepaintBoundary.toImage` throws `!debugNeedsPaint` (flutter#40064) because offscreen widgets aren't painted. | Mount the card via an **`OverlayEntry` off the viewport** so it is genuinely painted; capture after one frame; then remove the entry. |
| **Web Share** | Web Share API needs HTTPS + **transient** user activation; Firefox has no Web Share. | Wire share directly to button `onTap` **before any `await`** (an intervening `await` loses the user activation and breaks `navigator.share`); feature-detect; rely on **Save** as the universal web path. |
| **Web file paths** | Browser sandbox exposes no real local paths; `file_saver` returns a download, not a path. | Make `ExportService` saves fire-and-forget; never read back a saved path. |
| **Linux** | `share_plus` cannot share files (text-only via mailto); `file_saver` has no `saveAs()` dialog. | Route "Share file" / "Save as…" through `file_saver.saveFile()`; offer only "Share text" via share sheet. |
| **Android (super_clipboard)** | Image/custom clipboard needs NDK (~1GB), minSdk 23, declared content provider. Rust toolchain auto-downloads (CI time). | Budget CI; document manifest entry; fall back to text-only `Clipboard` where image-copy isn't worth the weight. |
| **iPad** | `ShareParams.sharePositionOrigin` is mandatory or the share sheet can crash/hang. | Pass the source widget's rect (RenderBox). |
| **Desktop** | Production-stable since Flutter 3.0 (Canonical-stewarded). | No special foundation work. |

---

## 10. Verification Log (this revision)

| Claim | Result (2026-06-19) | Source |
|---|---|---|
| `super_clipboard` web PNG-copy | **Demoted to best-effort.** Docs affirm only **text-only** web writes (copy/cut handlers; Firefox); programmatic image-write web path unconfirmed for all browsers; docs recommend "regular clipboard API" without confirming image support. | pub.dev/packages/super_clipboard (0.9.1) |
| `screenshot` package currency | **Stale: 3.0.0, published ~2 years ago, requires Flutter ≥3.22; `captureAndSave` not supported on web.** **Dropped** in favor of framework primitives. | pub.dev/packages/screenshot |
| Offscreen capture without a package | Naive `Offstage`+`toImage` asserts `!debugNeedsPaint`; mount via off-viewport `OverlayEntry` so it paints, then `toImage`. Works on web. | flutter/flutter#40064; slightfoot gist |
| Drift FTS5 on web | **True.** `sqlite3.wasm` ships FTS5+json1; same query native+web. `drift_dev` needs `modules: [fts5, json1]` in `build.yaml` to parse the DDL. | drift.simonbinder.eu generation_options / extensions |
| CanvasKit `toImage` raster bug | **Real** (flutter#106314 since Flutter 3.0; native unaffected). Text+vector card sidesteps it → hard rule. | flutter/flutter#106314 |
| `flutter_riverpod`/`go_router` versions; legacy providers | Accepted as stated; offline-persistence marked **experimental** and kept out of durability path. | (prior verification; unchanged) |
| `share_plus` 13.1.0 / `file_saver` 0.4.0 / Linux + iPad caveats | Accepted as stated; no change (share-onTap-before-await rule kept prominent). | (prior verification; unchanged) |
| Supabase/RLS/UUIDv7/LWW | Accepted; added deterministic same-ms tiebreaker; `supabase_flutter` version to be re-verified at adoption. | (prior verification; unchanged) |

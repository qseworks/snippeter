# Implementation Notes

Where the build deliberately deviates from `ARCHITECTURE.md`, and why. Everything below is intentional, not an oversight.

## FTS5 created via `customStatement`, not a `.drift` file
The plan declared the `snippets_fts` virtual table + triggers in a `.drift` file. We instead create them with raw `customStatement`s in the Drift `onCreate` migration (`lib/core/db/app_database.dart`). Cross-referencing Dart-defined tables from a `.drift` file's triggers is brittle; raw statements are robust and fully covered by `test/search_test.dart`. The FTS table is **standalone** (stores its own copy) with triggers mirroring `snippets` and re-denormalizing `tag_text` from `snippet_tags`. The `build.yaml` `fts5`/`json1` modules remain (harmless; needed if we move FTS into `.drift` later).

## Copy-PNG-to-clipboard intentionally omitted
Per the architecture's adversarial review, programmatic image-to-clipboard on web is unverified, and `super_clipboard` pulls in a Rust build toolchain. We therefore ship the **guaranteed** image paths only — **Save PNG** (`file_saver` download) and **Share** (`share_plus`). Plain-text copy uses Flutter's built-in `Clipboard`. "Copy image" remains the deferred Phase-5 spike.

## CanvasKit baseline; `--wasm` not required
`re_editor` is not WASM-clean, so `flutter build web --wasm` is not the shipping target. The default **CanvasKit** build is what we ship (and it builds cleanly). This matches the plan's "CanvasKit baseline, WASM as progressive enhancement."

## Off-screen capture uses framework primitives
No `screenshot` package (stale). The carbon card is captured by mounting it in an off-viewport `OverlayEntry` + `RepaintBoundary.toImage(pixelRatio: 3.0)` (`lib/features/export/presentation/widget_image_capture.dart`). The card is **text + vector only**; `test/export_card_test.dart` asserts there is no raster `Image`, guarding the web `toImage` raster bug.

## Modern theme + language-aware highlighting (design refresh)
- **Bundled type.** Inter (UI, variable) and JetBrains Mono (code) ship in `assets/fonts/` and are wired in `pubspec.yaml` → `AppTheme.uiFamily` / `AppTheme.monoFamily`. This is offline-first and makes PNG export **pixel-stable across every platform**, resolving the previously-deferred "bundled font (Phase 6)" item.
- **Design system.** `lib/core/theme/app_theme.dart` is a full Material 3 system: expressive violet scheme, deepened near-black dark surfaces, Inter type scale, a 10/14/20 corner vocabulary, hairline (`outlineVariant`) borders over shadows, and component theming for app bar, cards, inputs (filled/borderless), chips, nav rail/bar, buttons, dialogs, menus, snackbars and tooltips.
- **Per-language identity.** `lib/core/highlight/language_visuals.dart` maps each seeded language to a brand accent + monogram via `LanguageBadge` / `LanguagePill` (used in cards, detail meta, filter chip, settings & editor dropdowns).
- **Code window.** `CodeBlock` (in `lib/core/widgets/code_view.dart`) renders the detail body as a titled window: language-badge header, line-number gutter, inline copy button, horizontal scroll. `CodeView` (compact, wrapping) still backs list previews. Highlighting itself is unchanged (`re_highlight`, all grammars).

## Deferred to a future pass
- **Web storage-fallback banner.** `drift_flutter`'s `driftDatabase()` abstracts which storage tier it chose, so surfacing an "in-memory fallback → data lost on reload" warning needs a switch to `WasmDatabase.open` directly. Deferred. In practice browsers land on IndexedDB and persist.
- **Global keyboard shortcuts** (e.g. ⌘N / ⌘F). Deferred to avoid fragile cross-widget focus plumbing; New is always reachable (FAB / header button).
- **Cloud sync.** `lib/features/sync/` is a compiling-but-unwired seam (`SyncedSnippetRepository`, `RemoteSnippetDataSource`, `SyncEngine`) that proves sync is a one-line provider swap. No Supabase code is built yet.

## Sync-readiness already in place (not deferred)
The hard-to-retrofit parts are done from v1: UUIDv7 text PKs, epoch-ms `created/updated/deleted_at`, soft-delete tombstones, and reserved `dirty`/`owner_id` columns on every syncable table.

# OPEN_QUESTIONS.md — Snippet Manager

Decisions deferred or needing real-device proof (from architecture review).

1. PNG-copy on web (super_clipboard programmatic image write) is unverified for all browsers — the Phase-5 spike on Chrome and Safari will decide whether 'Copy image' ships on web or whether the web UI permanently degrades to 'Save image'. Needs a real device/browser test, not a docs claim.
2. supabase_flutter's exact current stable version was intentionally NOT pinned (sync is deferred to Phase 7) — re-verify at adoption time rather than carrying a possibly-stale version number now.
3. Pixel-exact PNG parity between CanvasKit web, skwasm/--wasm, and native is not guaranteed (toImage anti-aliasing differences, flutter#165380) even with a text+vector card; acceptable-difference threshold for the Phase-5/6 visual diff needs to be defined.
4. powersync vs hand-rolled outbox is still an open build-vs-buy decision deferred to sync adoption; the schema supports both but the choice (and powersync's web maturity) must be re-evaluated then.
5. re_highlight is at an early 0.0.x version number; if a needed grammar is missing or it stalls, the fallback is flutter_highlighting (190+ langs, ~3yr stale) or syntax_highlight — confirm grammar coverage for the launch language set during Phase 2.
6. Web persistence depends on the Drift tiered fallback (OPFS needs COOP/COEP; Safari/iOS-web is reduced) — the in-memory worst case loses data on reload, so the startup storage-impl detection + user warning banner must be validated on Safari/iOS-web specifically.

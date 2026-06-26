# Snippeter for Chrome

A Manifest V3 browser extension for **Snippeter** — a fast, local-first manager
for code snippets & AI prompts. Save any text selection straight into your
library, then search, copy, and paste snippets into any page from the toolbar
popup.

This extension is **dependency-free** (vanilla JS + `fetch`, no bundler). It
loads unpacked with **zero build step** — there is nothing to install or
compile.

## Load it unpacked

1. Open `chrome://extensions` in Chrome (or `edge://extensions` in Edge).
2. Toggle **Developer mode** on (top-right).
3. Click **Load unpacked**.
4. Select this folder: `integrations/chrome/`.
5. Pin **Snippeter** to your toolbar for quick access.

The extension talks to the live Snippeter backend. Sign in with the same email
and password you use in the Snippeter app.

## Features

- **Sign in** with email + password (Supabase GoTrue). Sessions are stored in
  `chrome.storage.local` and auto-refresh on expiry.
- **Save selection to Snippeter** — right-click any selected text on a page and
  choose the context-menu item. The page title becomes the snippet title; the
  language is inferred from the URL/content. A badge and notification confirm
  the save.
- **Search your library** — the popup lists your snippets newest-first, with a
  live search across title, language, description, and body.
- **Copy** — click a snippet title or its **Copy** button to copy its content
  (first file, falling back to `body`) to the clipboard.
- **Insert into page** — injects the snippet's content into the focused
  input / textarea / contenteditable on the active tab, with an
  `execCommand('insertText')` fallback.
- **Sign out** — clears the local session.

## How it talks to the backend

All requests go to the Supabase project at
`https://xxxxxxxxxxxxxxxxxxxx.supabase.co` using the **publishable (anon) key**,
which is safe to embed in clients. Row-Level Security scopes every row to the
signed-in user and their team workspaces.

- Auth: `POST /auth/v1/token?grant_type=password` (sign in),
  `grant_type=refresh_token` (refresh).
- Snippets: `GET /rest/v1/snippets?...&deleted_at=is.null&order=updated_at.desc`.
- Files: `GET /rest/v1/snippet_files?...&snippet_id=eq.{id}&order=position.asc`.
- Create: `POST /rest/v1/snippets` then `POST /rest/v1/snippet_files`
  (the snippet `body` mirrors the first file's content; `owner_id` is left to
  the server default).

## File layout

```
integrations/chrome/
├─ manifest.json        MV3 manifest (popup + service worker)
├─ background.js        Context menu + save-selection service worker
├─ popup.html           Popup markup (sign-in + snippet list)
├─ popup.css            Dark theme in the Snippeter brand palette
├─ popup.js             Popup controller (auth, list, copy, insert)
├─ lib/
│  └─ api.js            REST client (GoTrue + PostgREST) + session storage
├─ icons/
│  └─ icon.svg          Logo mark — prompt chevron + green caret on a dark tile
└─ README.md            This file
```

## Permissions

| Permission        | Why |
| ----------------- | --- |
| `storage`         | Persist the auth session locally. |
| `contextMenus`    | Add the "Save selection to Snippeter" right-click item. |
| `scripting`       | Inject the snippet into the focused field on the page. |
| `activeTab`       | Read the active tab's title/URL when saving. |
| `notifications`   | Confirm saves from the background worker. |
| `host_permissions`| Talk only to the Snippeter Supabase project. |

## Generating PNG icons later (optional)

Chrome accepts the bundled `icons/icon.svg` for the toolbar. If you want raster
PNGs for the Chrome Web Store listing or to silence platform-specific
notification icon quirks, generate them from the SVG, e.g.:

```sh
# Using rsvg-convert (brew install librsvg)
rsvg-convert -w 16  -h 16  icons/icon.svg -o icons/icon16.png
rsvg-convert -w 48  -h 48  icons/icon.svg -o icons/icon48.png
rsvg-convert -w 128 -h 128 icons/icon.svg -o icons/icon128.png
```

Then point `manifest.json` `"icons"` (and `action.default_icon`) at the PNGs.

## Brand

Accent green `#65EA92`, deep green `#5EE38B`, dark background `#0F1115`, surface
`#161A21`, elevated `#1C212B`, hairline border `#262B36`, text `#E6E9EF`, muted
`#8A93A2`. Typeface Inter (wordmark Space Grotesk SemiBold). Logo mark: a terminal
prompt chevron `>` plus a green block caret on a dark rounded tile (the "prompt"
awaiting a snippet).

# Supabase backend

Backend for the snippet manager (P2). Project ref: `xxxxxxxxxxxxxxxxxxxx`
(region ap-south-1). The Postgres schema (snippets/files/labels/collections/
prompt-meta/attachments/versions + workspaces/members/invites) is defined by the
migrations in `supabase/migrations/` — per-user RLS + Realtime enabled — and the
hosted project mirrors them 1:1 (same version numbers).

> 💡 **Develop for free, offline.** You don't need the paid hosted project during
> development — run the whole Supabase stack locally in Docker. See
> [`../docs/local-dev.md`](../docs/local-dev.md).

## Edge functions

### `share` — public read-only snippet pages (P2.5) — **DEPLOYED**
Serves the HTML of a snippet whose `visibility = 'public'` (no auth;
`verify_jwt = false`). Deployed via the Supabase MCP (re-deploy with the CLI if
needed):

```bash
supabase functions deploy share --no-verify-jwt --project-ref xxxxxxxxxxxxxxxxxxxx
```

Public snippets are served at:

```
https://xxxxxxxxxxxxxxxxxxxx.supabase.co/functions/v1/share?id=<snippetId>
```

The app surfaces this URL in a snippet's share row when its visibility is Public.

> ⚠️ **Browser rendering caveat.** On Supabase's shared `*.supabase.co/functions`
> domain, the gateway forces `Content-Type: text/plain` + `X-Content-Type-Options:
> nosniff` + a `Content-Security-Policy: sandbox` on function responses (an
> anti-abuse/anti-phishing measure). So the page is served correctly but a
> browser shows the HTML **as source rather than rendering it**. To get a
> rendered page, attach a **custom domain** to Edge Functions (Supabase Dashboard
> → Edge Functions → Custom domains), after which the URL renders normally. For
> offline/rendered sharing today, the app's **Export → Save as HTML** already
> produces a self-contained, properly-rendered page.

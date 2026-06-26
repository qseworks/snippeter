# Supabase backend

Backend for the snippet manager (P2). The Postgres schema (snippets/files/labels/
collections/prompt-meta/attachments/versions + workspaces/members/invites) is
defined by the migrations in `supabase/migrations/` — per-user RLS + Realtime
enabled. These migrations are the single source of truth and bring up an
identical backend whether local or hosted.

> 💡 **Currently local-only.** There is no hosted project right now — development
> runs the whole Supabase stack locally in Docker (free). See
> [`../docs/local-dev.md`](../docs/local-dev.md). When you want a cloud backend
> again, create a new project, `supabase link` + `supabase db push` the
> migrations, and deploy the edge function (below).

## Edge functions

### `share` — public read-only snippet pages (P2.5)
Serves the HTML of a snippet whose `visibility = 'public'` (no auth;
`verify_jwt = false`). Served automatically by `supabase start` at
`http://127.0.0.1:55321/functions/v1/share?id=<snippetId>`. To deploy to a
hosted project (once you create one):

```bash
supabase functions deploy share --no-verify-jwt --project-ref <your-project-ref>
```

Public snippets are then served at:

```
https://<your-project-ref>.supabase.co/functions/v1/share?id=<snippetId>
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

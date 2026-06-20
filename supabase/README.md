# Supabase backend

Backend for the snippet manager (P2). Project ref: `xxxxxxxxxxxxxxxxxxxx`
(region ap-south-1). The Postgres schema (snippets/files/labels/collections/
prompt-meta/attachments/versions + workspaces/members/invites) was applied via
migrations through the Supabase MCP, with per-user/RLS and Realtime enabled.

## Edge functions

### `share` — public read-only snippet pages (P2.5)
Serves an HTML page for a snippet whose `visibility = 'public'`. Reader access
needs **no auth**, so it must be deployed with JWT verification OFF.

> ⚠️ Not deployed yet — deploying an unauthenticated, service-role-backed public
> function is a production action that needs explicit approval. Deploy it with:

```bash
supabase functions deploy share --no-verify-jwt --project-ref xxxxxxxxxxxxxxxxxxxx
```

Once deployed, public snippets are viewable at:

```
https://xxxxxxxxxxxxxxxxxxxx.supabase.co/functions/v1/share?id=<snippetId>
```

The app surfaces this URL in a snippet's share row when its visibility is Public.

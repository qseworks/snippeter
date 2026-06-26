# Local development with Supabase (no cloud cost)

The app is **offline-first** — local Drift is always the source of truth, and
Supabase is the optional sync/account/team backend. For day-to-day development
you don't need the paid hosted project at all: run the **entire Supabase stack
locally in Docker** (Postgres + Auth + Storage + Realtime + Edge Functions +
Studio). It's free and disposable.

There is **no hosted project right now** — the old one was deleted, so development
is fully local. When you want a cloud backend again, create a fresh project and
push these same migrations to it (see
[Going back to the cloud](#going-back-to-the-cloud)).

## Prerequisites

- A Docker engine running. This machine uses **Colima** (`colima start`); Docker
  Desktop works too.
- The Supabase CLI (`supabase --version`).

## Start / stop the local stack

```bash
supabase start     # boots the stack and applies supabase/migrations/*
supabase status    # show URLs + keys
supabase stop      # stop (keeps the DB volume, so data persists)
supabase db reset  # wipe + re-apply all migrations + seed.sql (fresh DB)
```

This project runs on a **shifted port block (`5532x`)** so it can run alongside
other local Supabase projects (which use the default `5432x`):

| Service          | URL                                      |
| ---------------- | ---------------------------------------- |
| API / REST       | http://127.0.0.1:55321                   |
| Postgres         | postgresql://postgres:postgres@127.0.0.1:55322/postgres |
| Studio (DB UI)   | http://127.0.0.1:55323                   |
| Mailpit (emails) | http://127.0.0.1:55324                   |
| Edge Functions   | http://127.0.0.1:55321/functions/v1      |

> Analytics/Logflare is disabled in `config.toml` because its `vector` container
> can't bind-mount the Docker socket under Colima. Only Studio's *Logs* panel is
> affected. Re-enable it (`[analytics] enabled = true`) if you move to Docker
> Desktop.

## Run the app against local

```bash
scripts/dev-local.sh -d macos     # desktop (recommended — localhost just works)
scripts/dev-local.sh -d chrome    # web
scripts/dev-local.sh              # let Flutter pick a device
```

The script starts the stack if needed, reads the live URL + publishable key from
`supabase status`, and passes them to Flutter via `--dart-define`. No secrets are
hard-coded — local keys are the standard, public Supabase demo keys.

### Accounts & email

Email confirmations are **off** locally, so you can **sign up inside the app and
log in immediately**. Any "confirmation"/reset email is captured by **Mailpit**
(http://127.0.0.1:55324) and never actually sent.

### Platform networking notes

| Target                         | Host the device uses        |
| ------------------------------ | --------------------------- |
| macOS / Linux / Windows / web  | `127.0.0.1` (default) ✅     |
| iOS simulator                  | `127.0.0.1` (default) ✅     |
| Android emulator               | `10.0.2.2` (auto-rewritten) |
| Physical phone                 | your LAN IP — `SUPABASE_HOST=192.168.x.y scripts/dev-local.sh -d <id>` |

Android also blocks cleartext HTTP by default. If you target Android over plain
`http://`, add a debug-only network-security config (ask and I'll wire it up) or
test on desktop/web/iOS-sim where it works out of the box.

## Changing the schema

`supabase/migrations/*` is the source of truth and matches the cloud project
1:1. To evolve the schema:

```bash
supabase migration new my_change   # create an empty timestamped migration, edit it
# ...or capture changes you made in Studio:
supabase db diff -f my_change      # writes the diff into a new migration file
supabase db reset                  # re-apply everything from scratch to verify
```

Edge functions live in `supabase/functions/`. `share` is served locally at
`http://127.0.0.1:55321/functions/v1/share?id=<snippetId>` (no JWT, matching the
deployed cloud function).

## Going back to the cloud

There is no hosted project anymore, so reactivation means creating a **new** one
and pushing these migrations to it:

```bash
supabase projects create snippeter            # or create it in the dashboard
supabase link --project-ref <new-project-ref> # one-time, asks for the DB password
supabase db push                              # applies all migrations to the new project
supabase functions deploy share --no-verify-jwt --project-ref <new-project-ref>
```

Because `supabase/migrations/` is the source of truth, the new project comes up
with the exact same schema, RLS, and triggers as your local stack.

Then point the app at it — no Dart edit required:

```bash
SUPABASE_URL=https://<new-project-ref>.supabase.co \
SUPABASE_ANON_KEY=<new-publishable-key> \
scripts/dev-remote.sh -d macos
```

(or bake those into the `--dart-define` defaults in
`lib/core/config/supabase_config.dart`). The four first-party integrations
(`integrations/cli`, `integrations/chrome`, `integrations/vscode`,
`integrations/jetbrains`) still hardcode the old URL — swap in the new project's
URL there too when you reactivate.

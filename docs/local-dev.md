# Local development with Supabase (no cloud cost)

The app is **offline-first** — local Drift is always the source of truth, and
Supabase is the optional sync/account/team backend. For day-to-day development
you don't need the paid hosted project at all: run the **entire Supabase stack
locally in Docker** (Postgres + Auth + Storage + Realtime + Edge Functions +
Studio). It's free and disposable.

The hosted project (`xxxxxxxxxxxxxxxxxxxx`) stays untouched; switch back to it
any time (see [Switching back to the cloud](#switching-back-to-the-cloud)).

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

## Switching back to the cloud

The compiled-in defaults already point at the hosted project, so:

```bash
scripts/dev-remote.sh -d macos   # or just: flutter run
```

When you've made schema changes locally and want to apply them to the hosted
project (after reactivating it):

```bash
supabase link --project-ref xxxxxxxxxxxxxxxxxxxx   # one-time, asks for the DB password
supabase db push                                   # pushes only NEW migrations
```

The 5 baseline migrations already exist on the remote with identical version
numbers, so `db push` will skip them and apply only what you added.

## Stopping the ~$10/month bill while you develop

Running locally costs nothing, but the hosted project keeps billing until you
park it. Options:

- **Pause the project** — Supabase Dashboard → project → *Pause*. Compute stops
  billing; restore it when you're ready (restoring can take a few minutes and
  the API is offline while paused). Your data and schema are preserved.
- **Downgrade the org to the Free plan** — fully $0, but Free has usage limits
  and auto-pauses after ~1 week of inactivity.

Either way your local stack is unaffected. Tell me which you want and I can pause
it for you via the Supabase tooling, or you can do it from the dashboard.

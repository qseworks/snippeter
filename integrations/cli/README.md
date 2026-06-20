# snip — Snippet Manager CLI

A small, self-contained command-line client for the
[Snippet Manager](../../README.md), talking directly to the project's Supabase
(PostgREST) backend. It signs you in with email/password and lets you list,
read, and create snippets from your terminal. Everything is scoped to your
account by Supabase Row Level Security.

This is an independent npm project under `integrations/cli/` and does not touch
the Flutter app.

## Requirements

- Node.js 20+ (developed/verified on Node 24)
- npm

## Install

From this directory (`integrations/cli/`):

```bash
npm install
npm run build       # compiles TypeScript to dist/
```

To get the `snip` command on your PATH, link it globally:

```bash
npm link            # exposes `snip` from dist/index.js
```

Or run it directly without linking:

```bash
node dist/index.js --help
```

### Development

```bash
npm run dev         # tsc --watch
```

## Usage

```
snip login                                  Sign in (prompts for email + password) and save the session
snip logout                                 Delete the saved session
snip whoami                                 Print the signed-in email, or "not signed in"
snip list [--query <text>]                  List your snippets (id, title, #files, updated date)
snip get <id> [--file <name>]               Print a snippet file's contents to stdout (first file by default)
snip add <file...> [--title <t>] [--private|--public]
                                            Create a snippet from one or more local files
snip --help                                 Show this help
```

### Examples

```bash
# Sign in (password input is hidden on a TTY; pipe it in scripts)
snip login
printf 'me@example.com\nsecret\n' | snip login   # non-interactive

# Who am I?
snip whoami

# List everything, or filter by title
snip list
snip list --query "react hook"

# Print the first file of a snippet (great for piping)
snip get 3f0c2b8e-... > out.txt
snip get 3f0c2b8e-... --file utils.ts | pbcopy

# Create a snippet from local files
snip add utils.ts --title "TS helpers"
snip add a.sql b.sql --title "Migration pair" --public
```

## Configuration

The Supabase URL and anon (publishable) key are baked in as defaults and can be
overridden via environment variables:

| Variable                     | Default                                          |
| ---------------------------- | ------------------------------------------------ |
| `SNIPPET_SUPABASE_URL`       | `https://xxxxxxxxxxxxxxxxxxxx.supabase.co`       |
| `SNIPPET_SUPABASE_ANON_KEY`  | baked-in publishable key                         |

## Session storage

After `snip login`, the access + refresh tokens are written to:

```
~/.config/snippet-manager/credentials.json   (chmod 600)
```

The session is restored on each invocation. If Supabase rotates the tokens
during restore, the refreshed tokens are written back automatically. Run
`snip logout` to delete the file.

## Notes

- Snippet content lives in `snippet_files` (a snippet has 1..N files, ordered by
  `position`); `snippets.body` mirrors the first file.
- Only non-deleted rows (`deleted_at is null`) are read.
- New snippets and files use app-generated UUIDs; `owner_id` is set by the
  server default and is never sent by the CLI.
- `language_id` is left null on `add`.
```

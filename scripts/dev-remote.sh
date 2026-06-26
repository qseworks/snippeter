#!/usr/bin/env bash
# Run the Flutter app against a REMOTE (hosted) Supabase project.
#
# There is no hosted project baked in anymore (the app defaults to offline), so
# you must supply a project's URL + publishable key. Export them before running:
#
#   SUPABASE_URL=https://<ref>.supabase.co \
#   SUPABASE_ANON_KEY=<publishable-key> \
#   scripts/dev-remote.sh -d macos
#
# With no creds set this just runs the app fully offline (local Drift only).
set -euo pipefail
cd "$(dirname "$0")/.."

ARGS=()
[[ -n "${SUPABASE_URL:-}" ]]      && ARGS+=(--dart-define=SUPABASE_URL="$SUPABASE_URL")
[[ -n "${SUPABASE_ANON_KEY:-}" ]] && ARGS+=(--dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY")

echo "▶ flutter run → REMOTE Supabase${SUPABASE_URL:+ ($SUPABASE_URL)}"
exec flutter run "${ARGS[@]}" "$@"

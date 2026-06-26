#!/usr/bin/env bash
# Run the Flutter app against the REMOTE (hosted) Supabase project.
#
# The app's compiled-in defaults (lib/core/config/supabase_config.dart) already
# point at the hosted project, so this is just `flutter run`. Provided for
# symmetry with dev-local.sh and as the obvious place to override creds later.
#
#   scripts/dev-remote.sh -d macos
#
# To point at a *different* hosted project without editing Dart, export these
# before running:  SUPABASE_URL=... SUPABASE_ANON_KEY=...
set -euo pipefail
cd "$(dirname "$0")/.."

ARGS=()
[[ -n "${SUPABASE_URL:-}" ]]      && ARGS+=(--dart-define=SUPABASE_URL="$SUPABASE_URL")
[[ -n "${SUPABASE_ANON_KEY:-}" ]] && ARGS+=(--dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY")

echo "▶ flutter run → REMOTE Supabase${SUPABASE_URL:+ ($SUPABASE_URL)}"
exec flutter run "${ARGS[@]}" "$@"

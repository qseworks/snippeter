#!/usr/bin/env bash
# Run the Flutter app against the LOCAL Supabase stack (`supabase start`).
#
#   scripts/dev-local.sh -d macos            # desktop app (recommended)
#   scripts/dev-local.sh -d chrome           # web
#   scripts/dev-local.sh                      # let Flutter choose the device
#   scripts/dev-local.sh -d emulator-5554     # Android emulator (host -> 10.0.2.2)
#   SUPABASE_HOST=192.168.1.20 scripts/dev-local.sh -d <id>   # physical device on your LAN
#
# Manage the stack with:  supabase start | supabase stop | supabase status
# Studio: http://127.0.0.1:55323   Mailpit (captured emails): http://127.0.0.1:55324
set -euo pipefail
cd "$(dirname "$0")/.."

# Make sure the local stack is up.
if ! supabase status >/dev/null 2>&1; then
  echo "▶ Local Supabase isn't running — starting it…"
  supabase start
fi

# Read the live URL + key from the running stack (honours the ports in config.toml,
# so this keeps working even if you change them later).
eval "$(supabase status -o env 2>/dev/null | sed 's/^/SB_/')"
URL="${SB_API_URL:?could not read API_URL — is the stack running?}"
KEY="${SB_PUBLISHABLE_KEY:-${SB_ANON_KEY:?could not read a local anon/publishable key}}"

# Pick the host the *device* can reach this computer on:
#  - macOS / Linux / Windows desktop, web, iOS simulator -> 127.0.0.1 works as-is.
#  - Android emulator -> the host is 10.0.2.2 (127.0.0.1 is the emulator itself).
#  - Physical device -> set SUPABASE_HOST to this computer's LAN IP.
if [[ -n "${SUPABASE_HOST:-}" ]]; then
  URL="${URL/127.0.0.1/$SUPABASE_HOST}"
elif printf '%s ' "$@" | grep -qiE 'emulator-|android'; then
  URL="${URL/127.0.0.1/10.0.2.2}"
  echo "ℹ Android target — using $URL (Android blocks cleartext HTTP by default; see docs/local-dev.md)"
fi

echo "▶ flutter run → LOCAL Supabase at $URL"
exec flutter run \
  --dart-define=SUPABASE_URL="$URL" \
  --dart-define=SUPABASE_ANON_KEY="$KEY" \
  "$@"

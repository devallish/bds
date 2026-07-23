#!/usr/bin/env bash
# Regenerates documents/BDS_Mobile_App_Database_Schema.md from the local Supabase
# database's actual schema using mermerd (https://github.com/KarnerTh/mermerd).
# Run this after any migration change; the local Supabase stack must be running.
set -euo pipefail

if ! command -v mermerd >/dev/null 2>&1; then
  echo "mermerd not found on PATH." >&2
  echo "Install it: see the Homebrew/manual install instructions in README.md." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_FILE="$REPO_ROOT/documents/BDS_Mobile_App_Database_Schema.md"
DB_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"

DIAGRAM=$(mermerd \
  -c "$DB_URL" \
  -s public \
  --useAllTables \
  -e \
  --showDescriptions notNull,enumValues,columnComments \
  --outputMode stdout)

cat > "$OUTPUT_FILE" <<EOF
# British Deer Society Mobile App — Database Schema

*Auto-generated from the local Supabase database's actual schema via [mermerd](https://github.com/KarnerTh/mermerd). Do not edit by hand — regenerate after any migration change by running \`supabase/scripts/generate-schema-diagram.sh\` (requires the local stack to be running: \`supabase start\`).*

$DIAGRAM
EOF

echo "Wrote $OUTPUT_FILE"

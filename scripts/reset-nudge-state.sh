#!/usr/bin/env bash
# reset-nudge-state.sh — (re)initialize .nudge-state.json for a project memory root.
# Usage: reset-nudge-state.sh <memory_root>

set -euo pipefail
if [[ $# -ne 1 ]]; then
  echo "usage: $0 <memory_root>" >&2
  exit 2
fi

ROOT="$1"
FILE="$ROOT/style-mem/.nudge-state.json"

mkdir -p "$ROOT/style-mem"
cat > "$FILE" <<'EOF'
{
  "edit_count": 0,
  "message_count": 0,
  "last_nudge_at": "1970-01-01T00:00:00Z",
  "threshold_edit": 10,
  "threshold_message": 20,
  "cooldown_seconds": 300
}
EOF

echo "nudge state reset at $FILE"

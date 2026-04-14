#!/usr/bin/env bash
# init-memory-store.sh — creates style-mem memory layout under a project's auto-memory dir.
# Usage: init-memory-store.sh <memory_root>
#   <memory_root> = e.g. ~/.claude/projects/-Users-ihoyeong-Documents-project-trot-iOS/memory

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <memory_root>" >&2
  exit 2
fi

ROOT="$1"
STORE="$ROOT/style-mem"

mkdir -p "$STORE/code" "$STORE/ux"

# rejected.md
if [[ ! -f "$STORE/rejected.md" ]]; then
  cat > "$STORE/rejected.md" <<'EOF'
# Rejected Rules

Rules listed here must NOT be re-proposed by style-observer.
EOF
fi

# Category file template
write_category () {
  local path="$1" name="$2" category="$3"
  if [[ -f "$path" ]]; then return; fi
  cat > "$path" <<EOF
---
name: $name
category: $category
updated: (never)
established_threshold: 0.7
---

# $name

## Established (confidence >= 0.7)

_(none yet)_

## Observed (confidence < 0.7)

_(none yet)_
EOF
}

write_category "$STORE/code/naming.md"         naming         code
write_category "$STORE/code/architecture.md"   architecture   code
write_category "$STORE/code/comments.md"       comments       code
write_category "$STORE/code/error_handling.md" error_handling code
write_category "$STORE/code/ui_layout.md"      ui_layout      code
write_category "$STORE/ux/ui_interaction.md"   ui_interaction ux
write_category "$STORE/ux/navigation.md"       navigation     ux

# MEMORY.md pointer line injection (single line, no per-rule index)
MEMORY="$ROOT/MEMORY.md"
LINE='- [style-mem rules](style-mem/) — 학습된 코딩/UX 스타일 (점진 강화)'
if [[ -f "$MEMORY" ]]; then
  if ! grep -Fq "style-mem/" "$MEMORY"; then
    printf '\n%s\n' "$LINE" >> "$MEMORY"
  fi
else
  printf '%s\n' "$LINE" > "$MEMORY"
fi

echo "style-mem store initialized at $STORE"

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

# INDEX.md
if [[ ! -f "$STORE/INDEX.md" ]]; then
  cat > "$STORE/INDEX.md" <<'EOF'
# style-mem Index

Last updated: (never)

## Code Conventions
- [naming](code/naming.md) — 변수/함수/타입 네이밍 규칙 (0 established, 0 observed)
- [architecture](code/architecture.md) — MVVM/RxSwift 구조 패턴 (0 established, 0 observed)
- [comments](code/comments.md) — 주석 작성 규칙 (0 established, 0 observed)
- [error_handling](code/error_handling.md) — 에러 처리 패턴 (0 established, 0 observed)
- [ui_layout](code/ui_layout.md) — Auto Layout / SnapKit 작성 스타일 (0 established, 0 observed)

## UX Patterns
- [ui_interaction](ux/ui_interaction.md) — 로딩/빈상태/에러/토스트 UI 패턴 (0 established, 0 observed)
- [navigation](ux/navigation.md) — 화면 전환 규칙 (0 established, 0 observed)
EOF
fi

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

# MEMORY.md index line injection
MEMORY="$ROOT/MEMORY.md"
LINE='- [style-mem index](style-mem/INDEX.md) — 학습된 코딩/UX 스타일 (점진 강화)'
if [[ -f "$MEMORY" ]]; then
  if ! grep -Fq "style-mem/INDEX.md" "$MEMORY"; then
    printf '\n%s\n' "$LINE" >> "$MEMORY"
  fi
else
  printf '%s\n' "$LINE" > "$MEMORY"
fi

echo "style-mem store initialized at $STORE"

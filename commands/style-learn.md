---
name: style-learn
description: Extract style signals from the current conversation and recent edits, then propose rules to save.
---

# /style-learn

Manual learning pass over the current conversation.

## Arguments
- (none) — analyze both conversation and recent edits
- `--category <c1,c2>` — restrict extraction to given categories
- `--edits-only` — only look at recent Edit/Write diffs
- `--convo-only` — only look at recent user/assistant messages

## Steps

1. Resolve the project's `style-mem/` memory root (under the auto-memory dir).
2. If it doesn't exist, **auto-bootstrap**: run `scripts/init-memory-store.sh <memory_root>` from the plugin. This creates the store AND injects a single pointer line to `style-mem/` into the project's `MEMORY.md`.
3. Invoke the `style-observer` skill with:
   - mode: `conversation`, `edits`, or both based on flags
   - category filter (if any)
4. Follow the observer's approval prompts exactly — do not auto-accept.
5. After observer finishes, print a one-paragraph summary:
   `저장 N개 / 거부 M개 / 건너뜀 K개. 카테고리별: code/naming +2, ux/navigation +1, ...`

## Constraints
- The user may hit Ctrl-C at the approval prompt. Treat that as "skip all remaining candidates" without writing.
- Never chain into `/style-apply` or any other command automatically.

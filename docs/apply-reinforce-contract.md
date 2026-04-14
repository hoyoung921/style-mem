# apply → reinforce contract

This file documents the contract between `style-apply` and `style-reinforce` so they stay in sync.

## Shared state file
Path: `<memory_root>/style-mem/.last-applied.json`

Schema:
```json
{
  "target_path": "string (repo-relative)",
  "applied_rule_ids": [
    { "category": "string, e.g. code/naming", "rule_id": "string, e.g. R1" }
  ],
  "applied_at": "ISO-8601 timestamp"
}
```

## Lifecycle
1. `style-apply` writes this file right before returning.
2. `style-reinforce` reads it when the user reacts.
3. `style-reinforce` deletes it after processing.
4. If `.last-applied.json` is older than 10 minutes when reinforce runs, reinforce treats it as stale and discards (no update).

## Invariants
- Only one `.last-applied.json` exists at a time. `style-apply` overwrites on each invocation.
- `applied_rule_ids` is never empty — if apply has nothing to apply, it does NOT write this file at all.
- The file is ignored by git (already in `.gitignore` via `.nudge-state.json` pattern — add `.last-applied.json` too).

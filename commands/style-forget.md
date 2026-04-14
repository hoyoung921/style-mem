---
name: style-forget
description: Remove a learned rule (by id, by category, or all) and record it in rejected.md so it is not re-proposed.
---

# /style-forget

Manual forgetting of rules.

## Arguments (mutually exclusive)
- `<rule-ref>` — e.g. `code/naming:R1`. Deletes that single rule.
- `--category <name>` — e.g. `--category code/comments`. Deletes ALL rules in that category.
- `--all` — deletes every rule in every category. Requires explicit double confirmation.

## Steps

1. Resolve memory root. If `style-mem/` missing, stop with scaffold instructions.
2. **Rule-ref mode** (`<rule-ref>` provided):
   a. Parse into `(category, rule_id)`.
   b. Read the category file.
   c. Find the rule block (established or observed).
   d. Show it to the user:
      ```
      🗑️ 삭제 후보
      <category> <rule_id>
      <title>
      Procedure:
        ...
      Confidence: <c>

      삭제할까요? [y/n]
      ```
   e. On `y`: remove the block, append to `rejected.md`, update INDEX.md counts.
3. **Category mode** (`--category`):
   a. Read the category file.
   b. Count rules. Show summary:
      ```
      🗑️ '<category>' 카테고리 삭제 후보: <N>개 규칙
      - <R1>: <title>
      - <R2>: <title>
      ...
      모두 삭제할까요? [y/n]
      ```
   c. On `y`: move each rule block to `rejected.md` (grouped under today's date), clear both sections in the category file, update INDEX.md.
4. **All mode** (`--all`):
   a. List every category with counts.
   b. First confirmation: `정말 모든 규칙을 삭제할까요? [y/n]`
   c. If `y`, second confirmation: `복구 불가능합니다. 한 번 더 확인해주세요. [yes/no]`
   d. Only on literal `yes`: execute.
   e. All category files reset to empty `## Established` / `## Observed` sections; every rule appended to `rejected.md`; INDEX.md counts reset.

## rejected.md append format
```
## 2026-04-14
- **Rule**: <title>
- **Category**: <category>
- **Rule ID (was)**: <rule_id>
- **Rejected because**: /style-forget (manual)
- **Do not re-propose**: true
```

## Safety
- Always show the rule body before deletion.
- `--all` requires two confirmations (`y` then `yes`).
- Never delete `rejected.md` itself.
- Never touch MEMORY.md.

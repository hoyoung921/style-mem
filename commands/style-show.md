---
name: style-show
description: Display learned coding style and UX rules from style-mem memory store.
---

# /style-show

Show learned style rules.

## Arguments
- (none) — show established rules for all categories
- `--category <name>` — show one category only
- `--all` — include observed rules too

## Steps

1. Resolve memory root for the current project:
   `~/.claude/projects/<PROJECT_SLUG>/memory/style-mem`
   (Use the same slug Claude Code uses for the current working directory's auto-memory.)

2. If the `style-mem/` directory does not exist, **auto-bootstrap**: run `scripts/init-memory-store.sh <memory_root>` from the plugin, then continue (the result will simply show zero rules).

3. Enumerate category files directly by listing `style-mem/code/*.md` and `style-mem/ux/*.md`. MEMORY.md is not used.

4. For each category file (filtered by `--category` if provided):
   - Use the Read tool on the category file.
   - Extract the `## Established` section.
   - If `--all`, also extract `## Observed`.

5. Render output to the user in this exact shape:
   ```
   📚 style-mem — 학습된 스타일 규칙

   ## code/naming  (established: 3, observed: 2)
   - R1 [conf 0.92, obs 7]: ViewModel의 Output은 Driver로 노출, Relay는 private
     Procedure:
       1. ...
       2. ...
   - R2 [conf 0.85, obs 4]: ...

   ## ux/ui_interaction  (established: 2, observed: 1)
   ...
   ```

6. If there are zero established rules across all categories AND `--all` not set, add a trailing hint:
   `아직 established 규칙이 없습니다. '/style-learn' 또는 '/style-scan <path>' 로 학습을 시작하세요.`

## Constraints
- Read-only. Never write to disk.
- Never invent rules not present in the files.
- Do not truncate procedures; show them in full.

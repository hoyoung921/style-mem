---
name: style-apply
description: Before Claude writes or edits code, load the established style-mem rules relevant to the target file and apply them while writing.
---

# style-apply

Runs just before Claude calls Edit or Write on a source file. Loads relevant established rules and informs the code being produced.

## When to invoke
- Automatically, at the start of any task where Claude will create or edit a `.swift` file.
- Manually, via `/style-apply-check <path>` (not part of Plan 2 — future extension).

## Procedure

1. **Receive target info** from the caller:
   - `target_path`: absolute or repo-relative file path
   - `layer_hint` (optional): one of `view` / `viewmodel` / `usecase` / `repository` / `other`
   - `task_description`: short sentence on what Claude is about to do

2. **Resolve style-mem memory root** for the current project.
   If `style-mem/` does not exist, log a single line `style-mem: not initialized, skipping` and return — never block the task.

3. **Infer layer** if `layer_hint` is missing, using filename suffix rules (same as `/style-scan`).

4. **Select relevant categories** based on layer:
   - `view` → `code/naming`, `code/ui_layout`, `code/comments`, `ux/ui_interaction`, `ux/navigation`
   - `viewmodel` → `code/naming`, `code/architecture`, `code/error_handling`, `code/comments`
   - `usecase` → `code/naming`, `code/architecture`, `code/error_handling`
   - `repository` → `code/naming`, `code/error_handling`
   - `other` → `code/naming`, `code/comments`

5. **Read the `## style-mem rules` section of MEMORY.md** to see which categories have any rules. For each relevant category that appears there, Read the corresponding category file under `style-mem/`.

6. **Extract established rules only.** Ignore `## Observed`.

7. **Conflict detection**: two established rules conflict if their `Procedure` steps contradict (e.g., "Output은 Driver" vs "Output은 PublishRelay"). If conflict found:
   - Pick the rule with higher `Confidence`.
   - Emit ONE user-facing line: `style-apply: '<category>'에서 충돌 감지 — <R_a> (conf <x>) 사용, <R_b> (conf <y>) 무시.`
   - Do NOT block the task.

8. **Emit an application plan** back to the caller in this format:
   ```
   style-apply: <target_path> (layer: <layer>)
   Applying N established rules:
     - [code/naming R1] ViewModel Output은 Driver, Relay는 private
     - [code/comments R3] MARK 주석은 한국어로
     - ...
   ```

9. **Track applied rules** by writing a small ephemeral file `<memory_root>/style-mem/.last-applied.json`:
   ```json
   {
     "target_path": "trot/Sources/Foo.swift",
     "applied_rule_ids": [
       {"category": "code/naming", "rule_id": "R1"},
       {"category": "code/comments", "rule_id": "R3"}
     ],
     "applied_at": "2026-04-14T10:30:00Z"
   }
   ```
   This is read by `style-reinforce` after the user reacts.

10. **Never write rules or modify category files.** This skill is read-only for rules.

## Safety
- Never block Edit/Write. If anything fails, log and proceed without rules.
- Observed rules are NEVER applied in Plan 2 (too noisy). Established only.
- If zero established rules are relevant, emit `style-apply: no rules for <target_path>` and return silently.

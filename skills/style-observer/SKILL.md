---
name: style-observer
description: Extract coding-style and UX-pattern rule candidates from conversation, recent edits, or scanned source files. Always gets user approval before writing.
---

# style-observer

Turns observations into rule candidates, then asks the user before saving.

## Categories (fixed)
- `code/naming`
- `code/architecture`
- `code/comments`
- `code/error_handling`
- `code/ui_layout`
- `ux/ui_interaction`
- `ux/navigation`

## Input modes
The caller (a command or hook) tells you which mode you are in:
1. **conversation** — analyze the last ~20 user/assistant messages.
2. **edits** — analyze the diffs of the last ~10 Edit/Write tool calls.
3. **scan** — a list of file paths (and their contents) is provided by `/style-scan`.
4. **nudge** — periodic self-check from `nudge-tracker`. Treat as combined (conversation + edits) but bias toward recent signals and only surface HIGH-signal candidates (skip one-shot observations). Be more conservative than manual modes.

## Procedure

1. **Load memory state**
   - Read `INDEX.md`, every category file, and `rejected.md` from the project's `style-mem/` store.
   - Build in memory: `existing_rules[(category, normalized_text)]` and `rejected_rules[(category, normalized_text)]`.

2. **Extract signals**
   - From the input mode, pick out concrete, repeatable signals (not one-off facts).
   - Convert each signal into a **procedure**, not a fact:
     - BAD: "camelCase를 쓴다"
     - GOOD: "새 변수를 선언할 때: 1) 첫 단어 소문자 2) 이후 단어 대문자 3) 약어는 전부 소문자"
   - Classify into one of the 7 categories. If it doesn't fit, drop it.

3. **Dedupe and filter**
   - If normalized text matches an existing rule: do NOT create a new candidate. Instead emit a `reinforce` candidate: `{category, rule_id, delta: +1}`.
   - If normalized text matches `rejected.md`: drop entirely. Do not propose.

4. **Assign initial confidence**
   - conversation mode: 0.3
   - edits mode: 0.3
   - scan mode, 1 file: 0.3
   - scan mode, ≥3 files with same signal: 0.5
   - scan mode with `--deep`, ≥10 files with same signal: 0.75
   - nudge mode: 0.35 (slightly higher than manual to reflect the "observed twice, independently" nature of signals that survived dedup across edits+conversation)

5. **Ask the user** (use the exact prompt in ../../docs/save-confirmation-prompt.md)
   - Group candidates by category, max 5 per prompt.
   - Options: `[y] save observed` / `[e] edit then save` / `[p] promote to established` / `[n] reject` / `[s] skip`.

6. **Persist**
   - For `y`: append under `## Observed` in the category file with frontmatter-style metadata block.
   - For `p`: append under `## Established` with `confidence >= 0.7`.
   - For `n`: append to `rejected.md` with today's date + reason.
   - For `e`: show edit, then apply `y`.
   - For `s`: no write.
   - After writing, update `INDEX.md` counts and `updated:` field.

7. **Return a summary**
   - Lines saved / rejected / skipped, per category.

## Rule entry format

When you append a new rule under `## Observed` or `## Established`, write it exactly in this shape:

```
### R<auto-increment>: <one-line title>
- **Procedure**:
  1. <step>
  2. <step>
- **Confidence**: <float 0.0–1.0>
- **Observed count**: <int>
- **First observed**: YYYY-MM-DD
- **Last reinforced**: YYYY-MM-DD
- **Evidence**:
  - <file:line or conversation reference>
```

Rule IDs are unique per category file. Read the file first to pick the next free ID (`R1`, `R2`, ...).

## Safety rules (non-negotiable)
- NEVER write to any file without first showing the candidate(s) to the user and receiving an explicit approval token (`y`, `e`, or `p`).
- NEVER propose rules that already exist in `rejected.md`.
- NEVER exceed 200 lines in MEMORY.md; this skill does not touch MEMORY.md at all (only INDEX.md and category files).
- ALWAYS record evidence (file path + line number, or conversation excerpt) for each rule.

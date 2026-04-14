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
   - Read every category file under `style-mem/` and `style-mem/rejected.md`.
   - Also read the `## style-mem rules` section of the project's `MEMORY.md` (the index).
   - Build in memory: `existing_rules[(category, normalized_text)]` and `rejected_rules[(category, normalized_text)]`.

2. **Extract signals**
   - From the input mode, pick out concrete, repeatable signals (not one-off facts).
   - Convert each signal into a **procedure**, not a fact:
     - BAD: "camelCase를 쓴다"
     - GOOD: "새 변수를 선언할 때: 1) 첫 단어 소문자 2) 이후 단어 대문자 3) 약어는 전부 소문자"
   - **Be concise**: title = one short line; Procedure = **max 3 steps**, each ≤ ~80 chars. Drop obvious/redundant steps. If a signal truly needs more, split into two rules rather than bloat one.
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
   - **Default: AskUserQuestion, one candidate per call, in Korean.**
     For each candidate, display the single-rule shape as text first, then
     invoke `AskUserQuestion` with exactly one question whose options are:
     `저장`, `수정`, `건너뛰기`.
   - Wait for the answer, resolve that rule, then move to the next candidate
     with another `AskUserQuestion` call. Never batch multiple candidates
     into a single AskUserQuestion call or a single prompt.
   - If the user picks `수정`, ask a follow-up `AskUserQuestion` (or accept
     free-form text) describing the edit, apply it, re-display, then ask
     again with the same 3 options.
   - Batch (multi-rule) form is opt-in only: use it when the user explicitly
     requests "일괄", "batch", or "한 번에".
   - NEVER invent bulk shortcut syntax like `y all`, `y all except E1`,
     `p A1 A2, y rest`, or any English combined reply. All prompts MUST be
     in Korean and go through AskUserQuestion, one rule at a time.

6. **Persist**
   - `저장`: append under `## Observed` in the category file with frontmatter-style metadata block.
   - `수정`: apply the user's edit, then save as `저장`.
   - `건너뛰기`: no write.
   - After writing, update the category file's `updated:` field, and append one
     line to the `## style-mem rules` section of `MEMORY.md` in this shape:
     `- [<category> R<id>: <title>](style-mem/<category_file>.md#r<id>) — <hook>`
     where `<hook>` is an optional short phrase (drop it if MEMORY.md is
     approaching 200 lines). Remove any `_(none yet ...)_` placeholder line
     in the section on first insert.

7. **Return a summary**
   - Lines saved / skipped, per category.

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
- NEVER write to any file without first showing the candidate to the user and receiving an explicit `저장` or `수정` answer via AskUserQuestion.
- NEVER propose rules that already exist in `rejected.md`.
- Only modify the `## style-mem rules` section of MEMORY.md. Never touch other sections.
- Keep MEMORY.md under 200 lines. If near the limit, drop the optional hook from new entries or shorten titles rather than bloating the file.
- ALWAYS record evidence (file path + line number, or conversation excerpt) for each rule.

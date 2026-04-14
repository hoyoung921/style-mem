---
name: style-reinforce
description: After the user reacts to Claude's code output (accept / modify / reject), update the confidence scores of the rules that were applied.
---

# style-reinforce

Closes the learning loop by reading user reactions and updating rule confidences.

## When to invoke
- Right after the user responds to a message where Claude produced code that had a preceding `style-apply` invocation.
- Triggers:
  - User says "good", "lgtm", "좋아", "완벽" with no edits → **accept**
  - User modifies the code (issues a follow-up Edit) → **modify**
  - User says "no, that's wrong", "틀렸어", or reverts → **reject**
  - Silence / unrelated next message → **no-op** (do not run)

## Confidence update formulas

Let `c` be the current confidence of a rule, bounded to [0, 1].

- **accept**: `c_new = c + alpha * (1 - c)`, where `alpha = 0.15`
- **modify in rule's direction** (edit still follows the rule): **no-op** (noise)
- **modify against rule** (edit reverses the rule): `c_new = c - beta * c`, where `beta = 0.25`
- **explicit reject** ("이 규칙 틀렸어", "no, that rule is wrong"): delete the rule + append to `rejected.md`

## Procedure

1. **Read** `<memory_root>/style-mem/.last-applied.json`.
   If missing or older than 10 minutes, do nothing and return.
2. **Classify reaction** per the triggers above. If ambiguous, do nothing.
3. For each `(category, rule_id)` in `applied_rule_ids`:
   a. Read the category file.
   b. Find the rule block (established or observed).
   c. Apply the formula for the reaction.
   d. Update `Confidence`, `Observed count (+1 on accept, +1 on modify-against)`, `Last reinforced: <today>`.
4. **Promotion**: if an observed rule crosses `>= 0.7`, show the promotion prompt:
   ```
   📈 '<category> R<id>'의 신뢰도가 0.7을 넘었습니다 (<new_conf>). Established 섹션으로 승격할까요? [y/n]
   ```
   If `y`, move the rule block from `## Observed` to `## Established`.
5. **Demotion**: if an established rule drops below `0.5`, automatically move it back to `## Observed` and emit a single line:
   `style-reinforce: '<category> R<id>' demoted to observed (conf <new>)`.
6. **Deletion candidate**: if any rule drops below `0.2`, show the deletion prompt:
   ```
   📉 '<category> R<id>'의 신뢰도가 <new>까지 떨어졌습니다. 삭제할까요?
   [y] 삭제 (rejected.md에 기록)
   [n] 유지
   ```
7. Never touch MEMORY.md. Promotions/demotions/deletions are recorded only in the category files and `rejected.md`.
8. **Delete `.last-applied.json`** after processing (prevents double-counting on next message).

## Worked examples

Starting conf 0.60, accept:
`c_new = 0.60 + 0.15 * (1 - 0.60) = 0.60 + 0.06 = 0.66`

Starting conf 0.60, modify-against:
`c_new = 0.60 - 0.25 * 0.60 = 0.60 - 0.15 = 0.45` → demotion check fires (now below 0.5 if it was established).

Starting conf 0.72 (established), accept:
`c_new = 0.72 + 0.15 * 0.28 = 0.72 + 0.042 = 0.762`

## Safety
- If reaction is ambiguous, do nothing. Never punish on unclear signals.
- Never create new rules. This skill only updates existing ones.
- Promotions require explicit user confirmation. Demotions do not (they fail-safe).
- Deletions require explicit user confirmation.

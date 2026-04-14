# Plan 3 End-to-end Manual Test

Exercises the full plugin: manual learning, automatic application, reinforcement, periodic nudge, and forgetting.

## Preconditions
- Fresh style-mem store (or backup existing first).
- Plans 1 & 2 pass.

## Scenario

1. **Backfill**: `/style-scan trot/Sources/Chat`. Approve 3 rules across different categories.
2. **Verify**: `/style-show` lists the 3 rules (all observed).
3. **Manual promote**: in `code/naming.md`, bump one rule's conf to 0.75 and move to established. Update the rule's line in MEMORY.md's `## style-mem rules` section if its title changed.
4. **Trigger apply**: ask Claude to create `trot/Sources/Test/E2EViewModel.swift`. Confirm style-apply logs the rule. Confirm generated code follows it.
5. **Accept reaction**: "완벽해, 이대로 써줘". Confirm confidence bumps up.
6. **Nudge simulation**:
   a. Run 10 rapid Edit calls by asking Claude to make small whitespace changes to `trot/Sources/Test/E2EViewModel.swift`.
   b. After the 10th edit, nudge-tracker should fire style-observer in nudge mode.
   c. Expected: observer surfaces any new repeated signals, or silently resets counters if none.
7. **Cooldown**: immediately run `/style-learn`. Then trigger another 10 edits. Verify nudge does NOT fire again within 5 minutes (check `.nudge-state.json.last_nudge_at`).
8. **Forget single rule**: `/style-forget code/naming:R1`. Confirm `y`. Verify removed + appended to `rejected.md`.
9. **Re-propose protection**: run `/style-learn` with the same signal that created R1. Must NOT propose it again.
10. **Forget all**: `/style-forget --all`. Answer `y`, then `yes`. Verify all category files are empty and rejected.md contains all former rules.

## Pass criteria
All 10 steps behave exactly as described. `.nudge-state.json` is respected (counter resets, cooldown enforced). `rejected.md` is append-only and never cleared.

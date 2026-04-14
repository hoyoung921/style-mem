---
name: nudge-tracker
description: Track Edit/Write and message counts toward the style-mem periodic nudge threshold. Fires style-observer in nudge mode when conditions are met.
---

# nudge-tracker

Maintains `.nudge-state.json` and decides whether to trigger a periodic nudge.

## When to invoke
- After every Claude response that involved at least one Edit or Write tool call.
- After every Claude response regardless of tools used (to count messages).

The two increments are orthogonal — both fire per-response.

## Procedure

1. **Locate state file**: `<memory_root>/style-mem/.nudge-state.json`.
   If missing, call `reset-nudge-state.sh` and start fresh.
2. **Increment counters**:
   - If the previous response contained ≥1 Edit or Write call: `edit_count += (number of edit/write calls)`.
   - Always: `message_count += 1`.
3. **Check fire conditions** (Section "Fire rule" in `docs/nudge-state-schema.md`):
   - `edit_count >= threshold_edit` OR `message_count >= threshold_message`
   - AND `now - last_nudge_at >= cooldown_seconds`
4. **If NOT firing**: persist counters and stop.
5. **If firing**:
   a. Invoke `style-observer` skill in mode `nudge` with input:
      - last ~10 Edit/Write diffs
      - last ~20 messages
   b. Observer runs its normal extract + dedup + approval loop.
   c. Whether or not any rules were saved, set:
      - `edit_count = 0`
      - `message_count = 0`
      - `last_nudge_at = <now ISO-8601>`
   d. Persist state.

## Silent mode
If the user has explicitly said "그만 제안해", "stop suggesting", or similar in the last 5 messages, skip firing for this cycle (still update `last_nudge_at` to enforce cooldown). This is a soft courtesy guard.

## Safety
- Never modify counters to values that would retroactively "catch up" — only the per-response delta.
- Never fire more than once per response cycle.
- Never interrupt an in-progress multi-step user task; wait until a response boundary.

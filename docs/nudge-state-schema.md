# .nudge-state.json schema

Location: `<memory_root>/style-mem/.nudge-state.json`
Git-ignored (see `.gitignore`).

```json
{
  "edit_count": 0,
  "message_count": 0,
  "last_nudge_at": "2026-04-14T10:30:00Z",
  "threshold_edit": 10,
  "threshold_message": 20,
  "cooldown_seconds": 300
}
```

## Fields
- `edit_count`: incremented by the nudge tracker each time Claude calls Edit or Write.
- `message_count`: incremented each time a new user/assistant message pair completes.
- `last_nudge_at`: ISO-8601. Updated whenever a nudge fires (success OR no-op).
- `threshold_edit`: edit count at which nudge fires. Default 10.
- `threshold_message`: message count at which nudge fires. Default 20.
- `cooldown_seconds`: minimum seconds between nudges. Default 300 (5 min).

## Fire rule
A nudge fires when ALL of the following are true:
1. `edit_count >= threshold_edit` OR `message_count >= threshold_message`
2. `now - last_nudge_at >= cooldown_seconds`

On fire: reset `edit_count = 0`, `message_count = 0`, set `last_nudge_at = now`.

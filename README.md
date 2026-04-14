# style-mem

Incremental coding-style and UX-pattern memory plugin for Claude Code.
Hermes Agent-inspired: observes, applies, and reinforces rules derived from your own code and conversation.

## Install

Symlink or copy into `~/.claude/plugins/style-mem/`.

## Commands

- `/style-learn` — extract style signals from the current conversation
- `/style-scan <path>` — backfill learning from existing feature code
- `/style-show` — list learned rules
- `/style-forget <rule-id>` — remove a rule (later plan)

See `docs/` for the design spec.

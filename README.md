# style-mem

Incremental coding-style and UX-pattern memory plugin for Claude Code.
Hermes Agent-inspired: observes, applies, and reinforces rules derived from your own code and conversation.

## Install

```bash
ln -sfn ~/Documents/project/style-mem ~/.claude/plugins/style-mem
~/Documents/project/style-mem/scripts/init-memory-store.sh \
  ~/.claude/projects/<your-project-slug>/memory
```

Restart Claude Code so the plugin manifest is picked up.

## Commands

- `/style-learn` — extract style signals from the current conversation and/or recent edits
- `/style-scan <path>` — backfill learning from existing feature code
- `/style-show` — list learned rules
- `/style-forget <rule-ref>|--category <name>|--all` — remove learned rules

## Skills (automatic)

- `style-observer` — converts signals into rule candidates (always asks before saving)
- `style-apply` — loads established rules before Claude edits/writes source files
- `style-reinforce` — updates rule confidence after user accepts / modifies / rejects code
- `nudge-tracker` — periodic self-check that fires the observer automatically

## Storage layout

All rules live under your project's Claude Code auto-memory directory:
```
<memory_root>/style-mem/
├── rejected.md
├── code/{naming,architecture,comments,error_handling,ui_layout}.md
└── ux/{ui_interaction,navigation}.md
```

The project's `MEMORY.md` gains a `## style-mem rules` section that indexes every saved rule as one line, pointing into the category files. This keeps the index visible in every future conversation while category files hold the full rule bodies. MEMORY.md is kept under 200 lines — hooks on entries are optional and may be trimmed if space runs low.

## Design docs

- Spec: `docs/superpowers/specs/2026-04-14-style-mem-plugin-design.md` (in the consuming project repo)
- Plan 1 (MVP): `.../plans/2026-04-14-style-mem-plan1-mvp.md`
- Plan 2 (reinforcement): `.../plans/2026-04-14-style-mem-plan2-reinforcement.md`
- Plan 3 (nudge + forget): `.../plans/2026-04-14-style-mem-plan3-nudge-forget.md`

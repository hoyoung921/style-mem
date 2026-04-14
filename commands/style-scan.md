---
name: style-scan
description: Backfill learning by scanning a feature directory for style and UX patterns.
---

# /style-scan

Walks a feature directory, extracts repeated style/UX signals, and proposes rules for approval.

## Arguments
- `<path>` — required. Target directory (relative to the current project).
- `--category <c1,c2>` — optional. Restrict extracted categories.
- `--deep` — optional. Read every file. Default is sampling (max 5 files per layer).

## Layer detection

Classify files under `<path>` by filename suffix / path component:
- `*ViewController.swift` or `*VC.swift` → `view`
- `*ViewModel.swift` or `*VM.swift` → `viewmodel`
- `*UseCase.swift` → `usecase`
- `*Repository.swift` → `repository`
- `*View.swift` (not VC) → `view`
- everything else → `other`

## Steps

1. Resolve the project's `style-mem/` memory root (under the auto-memory dir).
2. If it doesn't exist, **auto-bootstrap**: run `scripts/init-memory-store.sh <memory_root>` from the plugin. This creates the store AND injects a `## style-mem rules` section into the project's `MEMORY.md`.
3. Use the Glob tool: `<path>/**/*.swift`.
4. Bucket matches into layers using the rules above.
5. **Sampling mode (default)**: take up to 5 files per layer, preferring the largest files (likely most representative). **Deep mode**: take all.
6. For each selected file, use the Read tool to load its contents.
7. Invoke the `style-observer` skill with `mode: scan` and pass:
   - the full list of (file_path, file_contents) pairs
   - the category filter (if any)
   - a flag: `deep: true|false` (affects initial confidence — see observer Step 4)
8. Observer runs its extraction + dedup + approval loop.
9. After completion, print a summary:
   `스캔 완료: <N>개 파일 검사, 후보 <M>개 중 저장 <S>개 / 거부 <R>개 / 건너뜀 <K>개.`

## Safety
- If `<path>` is outside the current working directory, refuse and tell the user to re-run from the project root.
- If `<path>` contains more than 500 `.swift` files in sampling mode, warn the user and ask for confirmation before proceeding.
- In `--deep` mode with >100 files, warn about token cost and ask for confirmation.

## Examples
```
/style-scan trot/Sources/Chat
/style-scan trot/Sources/Diary --category naming,ui_interaction
/style-scan trot/Sources/Vote --deep
```

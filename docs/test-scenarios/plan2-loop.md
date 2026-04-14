# Plan 2 Manual Test — full learning loop

Runs through the full observe→apply→reinforce cycle by hand.

## Preconditions
- Plan 1 MVP works; style-mem store exists for trot-iOS.
- No style-mem rules yet (fresh store or backup existing first).

## Steps

### 1. Seed a rule via /style-learn
1. Tell Claude: "한국어 MARK 주석 써줘. 영어는 쓰지 마."
2. Run `/style-learn --convo-only`.
3. Approve with `y`. Rule lands in `code/comments.md` as observed, conf 0.3.

### 2. Promote manually to test apply
1. Edit `code/comments.md` and bump conf to `0.75`, move block to `## Established`.
2. Update INDEX.md count: `(1 established, 0 observed)`.

### 3. Apply during a task
1. Ask: "trot/Sources/Test/Scratch.swift 라는 간단한 ViewController 템플릿 만들어줘."
2. Before Edit, style-apply should log:
   `style-apply: trot/Sources/Test/Scratch.swift (layer: view)`
   with R1 listed.
3. Check that generated file uses `// MARK: - 뷰 구성` style Korean MARK.
4. Verify `.last-applied.json` exists at the memory root.

### 4. Accept reaction → confidence up
1. Reply to Claude: "좋아, 그대로 써줘."
2. style-reinforce should fire.
3. Expected formula: `0.75 + 0.15 * 0.25 = 0.7875`.
4. Verify category file: `Confidence: 0.79` (rounded to 2 decimals).
5. `.last-applied.json` deleted.

### 5. Modify-against reaction → confidence down
1. Ask for another ViewController; same rule applied (still established).
2. Manually edit the generated MARK to English: `// MARK: - View Setup`.
3. Say "이렇게 써줘, 영어로".
4. style-reinforce should detect modify-against.
5. Expected: `0.7875 - 0.25 * 0.7875 = 0.5906...`. Still established (>= 0.5).
6. Next accept/modify cycles should eventually drop below 0.5 → auto-demotion.

### 6. Explicit reject → deletion
1. Seed another rule manually and make Claude apply it.
2. Reply: "이 규칙 틀렸어, 쓰지 마."
3. Expected: rule deleted, appended to `rejected.md`.
4. Re-run `/style-learn` with the same signal → must NOT re-propose (rejected block).

## Pass criteria
All 6 steps above behave exactly as described. Any deviation = bug.

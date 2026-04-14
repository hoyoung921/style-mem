# Save Confirmation Prompt (shared)

Both `/style-learn`, `/style-scan`, and the observer skill MUST use this exact prompt shape when asking the user to save candidates. This file is the single source of truth — update it here, not in each skill.

## Single-rule form

```
📝 새 코딩 스타일 규칙 후보

카테고리: <category>
규칙: <one-line title>
절차:
  1. <step>
  2. <step>
신뢰도: <float> (관찰 <count>회)
근거:
  - <file:line or conversation excerpt>
  - ...

이 규칙을 저장할까요?
- 저장 (observed 섹션)
- 수정 후 저장
- 건너뛰기 (이번만 저장 안 함, 다시 제안 가능)
```

## Interactive one-by-one form (default, via AskUserQuestion)

This is the **default** mode. For each candidate:

1. Print the single-rule shape above as plain text (so the user can read the
   full rule).
2. Call `AskUserQuestion` **once**, with a single question and these three
   options (labels in Korean):
   - `저장` — observed 섹션에 저장
   - `수정` — 내용 수정 후 저장
   - `건너뛰기` — 이번만 저장 안 함

Rules:
- Exactly **one candidate per AskUserQuestion call**. Never bundle multiple
  candidates into one question, and never list them in a single prompt.
- Do NOT show or ask about the next candidate until the current one is
  resolved.
- If the user chooses `수정`, follow up (another AskUserQuestion or
  free-form text) to capture the change, apply it, re-print the updated
  single-rule shape, and ask again with the same 3 options.
- After resolving, print a short progress line like
  `(2/7 처리됨, 다음 규칙으로 넘어갑니다)` and continue with the next
  AskUserQuestion call.

## Multi-rule (batch) form — opt-in only

Only use this when the user explicitly asks for it ("일괄로 보여줘", "batch",
"한 번에"). Group by category, max 5 rules per prompt. Number them and
collect a space-separated reply:
`답변 예시: y e p n s` → 순서대로 규칙 1~5에 적용.

## Response normalization
- Uppercase/lowercase same meaning.
- Unknown token → treat as `s` (skip) and warn.
- In one-by-one mode, free-form edit text → implicit `e`.

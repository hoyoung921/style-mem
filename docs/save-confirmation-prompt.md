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
[y] 저장 (observed 섹션)
[e] 수정 후 저장
[p] 승격 저장 (바로 established)
[n] 거부 (rejected.md에 기록, 재제안 안 함)
[s] 건너뛰기 (이번만 저장 안 함, 다시 제안 가능)
```

## Multi-rule form
Group by category, max 5 rules per prompt. Number them and collect a space-separated reply:
`답변 예시: y e p n s` → 순서대로 규칙 1~5에 적용.

## Response normalization
- Uppercase/lowercase same meaning.
- Unknown token → treat as `s` (skip) and warn.

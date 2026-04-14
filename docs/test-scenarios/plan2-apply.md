# Plan 2 Manual Test Scenarios — style-apply

These are scripted reproductions to verify `style-apply` works correctly.

## Scenario A: single rule application
1. Ensure `code/naming.md` has one established rule `R1` (conf 0.9): "ViewModel Output은 Driver".
2. Ask Claude: "trot/Sources/Test/FooViewModel.swift 파일을 만들어서 상태를 노출해줘."
3. Before Edit/Write, Claude invokes style-apply.
4. Expected output line: `style-apply: trot/Sources/Test/FooViewModel.swift (layer: viewmodel)` and rule R1 listed.
5. Expected generated code: uses `Driver<T>` for output, not `BehaviorRelay<T>`.

## Scenario B: conflict resolution
1. Manually add a second established rule `R2` (conf 0.6) to `code/naming.md`: "ViewModel Output은 BehaviorRelay로 직접 노출".
2. Repeat Scenario A step 2.
3. Expected: style-apply prints conflict line, uses R1 (higher confidence).

## Scenario C: observed ignored
1. Add a rule to `code/naming.md` under `## Observed` (conf 0.4): "Input은 생략하고 함수로만".
2. Ask Claude to build a ViewModel.
3. Expected: observed rule is NOT applied; no mention in style-apply output.

## Scenario D: no rules
1. Empty `code/error_handling.md` (no established rules).
2. Ask Claude to modify a repository file.
3. Expected: `style-apply: no rules for <path>`. Task proceeds normally.

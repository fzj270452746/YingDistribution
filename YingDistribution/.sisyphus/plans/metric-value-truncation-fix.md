# Metric Value Truncation Fix

## TL;DR

> **Quick Summary**: Fix truncation of the `Expected Value` and `Total Simulations` numbers in the `Consolidated Metrics` section by updating the shared `CobaltCard` value label to shrink-to-fit instead of truncating.
>
> **Deliverables**:
> - Shared metric-card label configuration updated in `YingDistribution/Views/Components/CobaltCard.swift`
> - Build verification and manual UI QA evidence for compact and larger device layouts
>
> **Estimated Effort**: Quick
> **Parallel Execution**: NO - sequential
> **Critical Path**: T1 → T2 → T3 → F1-F4

---

## Context

### Original Request
Fix the truncated numeric values shown under `Expected Value` and `Total Simulations` in the `Consolidated Metrics` view.

### Interview Summary
**Key Discussions**:
- The user clarified the issue appears specifically under `Consolidated Metrics`.
- The user selected **Manual QA only** for verification.
- The user selected **Shrink to fit** rather than value abbreviation.

**Research Findings**:
- `Consolidated Metrics` is implemented in `YingDistribution/Views/Screens/AmethystAnalysis.swift`.
- Both affected metrics are rendered by the shared `CobaltCard` component in `YingDistribution/Views/Components/CobaltCard.swift`.
- The parent row uses equal-width cards with fixed height, so width expansion is not the right fix.
- `valueLabel` is a UIKit `UILabel` using a large monospaced font without shrink-to-fit behavior, causing truncation on compact widths.

### Metis Review
**Identified Gaps** (addressed):
- Needed an explicit user choice between shrinking text and abbreviating values → resolved: **shrink to fit**.
- Needed explicit guardrails preventing layout redesign or formatter changes → captured below.
- Needed acceptance criteria for compact-device rendering and shared-component regression coverage → added below.

---

## Work Objectives

### Core Objective
Ensure the `Expected Value` and `Total Simulations` metric values display fully in `Consolidated Metrics` without ellipsis, while preserving the exact numeric values and the existing card layout.

### Concrete Deliverables
- Update `CobaltCard.valueLabel` configuration to shrink when content exceeds available width.
- Produce build and manual QA evidence showing the two affected values are no longer truncated.

### Definition of Done
- [ ] `Expected Value` shows its full exact value in `Consolidated Metrics` without truncation on a compact iPhone layout.
- [ ] `Total Simulations` shows its full exact value in `Consolidated Metrics` without truncation on a compact iPhone layout.
- [ ] The same cards remain visually aligned and readable on a larger device layout.
- [ ] `xcodebuild -project YingDistribution.xcodeproj -scheme YingDistribution -destination 'platform=iOS Simulator,name=iPhone 15' build` succeeds.

### Must Have
- Preserve exact values; do not abbreviate to K/M/B.
- Keep the existing equal-width card layout intact.
- Implement the fix in the shared `CobaltCard` component.

### Must NOT Have (Guardrails)
- Do not modify number formatting logic.
- Do not redesign `AmethystAnalysis` layout, card spacing, fixed heights, or stack distribution.
- Do not change global typography constants.
- Do not add tests, new dependencies, or unrelated visual cleanup.
- Do not touch files outside the minimal component/verification scope unless required for evidence.

---

## Verification Strategy

> **Manual QA only** per user decision. No automated test infrastructure exists in this project.

### Test Decision
- **Infrastructure exists**: NO
- **Automated tests**: None
- **Framework**: none

### QA Policy
- Mechanical verification: build the app with `xcodebuild`.
- Hands-on verification: run the UI on at least one compact device and one larger device, navigate to `Consolidated Metrics`, and visually confirm the two values render fully with no ellipsis.
- Evidence saved to `.sisyphus/evidence/`.

---

## Execution Strategy

### Parallel Execution Waves

Wave 1 (Sequential implementation and targeted verification):
- Task 1: Update shared metric-card value label behavior in `CobaltCard`
- Task 2: Verify no layout/config regression in `AmethystAnalysis` and other `CobaltCard` consumers
- Task 3: Build and perform manual UI QA with evidence capture

Wave FINAL:
- F1 Plan compliance audit
- F2 Code quality review
- F3 Manual QA audit
- F4 Scope fidelity check

Critical Path: T1 → T2 → T3 → F1-F4

---

## TODOs

- [x] 1. Enable shrink-to-fit behavior for shared metric card values

  **What to do**:
  - Update `YingDistribution/Views/Components/CobaltCard.swift` so `valueLabel` preserves the current baseline typography but automatically shrinks when the text exceeds available width.
  - Configure the label with properties appropriate for UIKit single-line numeric rendering, such as `adjustsFontSizeToFitWidth`, a safe `minimumScaleFactor`, and tightening behavior if needed.
  - Keep the label single-line and preserve existing paddings/constraints.

  **Must NOT do**:
  - Do not change `AmethystAnalysis.swift` card layout or constraints.
  - Do not abbreviate values or alter formatting helpers.
  - Do not change `CinnabarTypography.VolumetricSize.vast`.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: single shared UIKit component change with narrow scope.
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `ui-ux-pro-max`: unnecessary; this is not a redesign task.

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Task 2, Task 3
  - **Blocked By**: None

  **References**:
  - `YingDistribution/Views/Components/CobaltCard.swift:27-35` - Current `valueLabel` configuration and exact shared fix point.
  - `YingDistribution/Views/Components/CobaltCard.swift:47-50` - Existing value-label constraints that must remain unchanged.
  - `YingDistribution/Views/Screens/AmethystAnalysis.swift:99-107` - `Consolidated Metrics` cards are rendered as equal-width siblings.
  - `YingDistribution/Views/Screens/AmethystAnalysis.swift:214-220` - The affected values are assigned here and must render fully after the shared component fix.

  **Acceptance Criteria**:
  - [ ] `CobaltCard.valueLabel` remains a single-line exact-value display.
  - [ ] The label no longer relies solely on default truncation when width is insufficient.
  - [ ] No layout constraint changes are introduced in `AmethystAnalysis.swift`.

  **QA Scenarios**:
  ```
  Scenario: Shared metric card shrinks instead of truncating
    Tool: Read + manual code review + app runtime QA
    Preconditions: `CobaltCard.swift` has been updated
    Steps:
      1. Open `YingDistribution/Views/Components/CobaltCard.swift`
      2. Confirm `valueLabel` includes shrink-to-fit configuration and still uses the existing monospaced font
      3. Confirm `valueLabel` constraints and single-line card structure remain unchanged
    Expected Result: The fix is limited to label rendering behavior, not layout redesign
    Failure Indicators: Constraint edits, formatter edits, global font edits, or missing shrink-to-fit properties
    Evidence: .sisyphus/evidence/task-1-metric-card-config.txt

  Scenario: No formatting logic introduced
    Tool: Read + Grep
    Preconditions: implementation complete
    Steps:
      1. Search changed files for added K/M/B abbreviation logic or formatter helpers
      2. Confirm existing exact value assignment sites remain unchanged
    Expected Result: Exact numeric values are preserved; only label display behavior changed
    Evidence: .sisyphus/evidence/task-1-no-abbreviation.txt
  ```

- [x] 2. Audit shared-component impact and preserve screen layout

  **What to do**:
  - Re-check `AmethystAnalysis.swift` to ensure the fix relies on the shared component and not a screen-level workaround.
  - Audit other known `CobaltCard` consumers to ensure the shared label change is acceptable and does not create obvious regression risk.

  **Must NOT do**:
  - Do not widen cards, reduce stack spacing, or alter fixed heights.
  - Do not perform unrelated copy or color changes.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: focused read-only audit of a small set of UIKit call sites.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Task 3
  - **Blocked By**: Task 1

  **References**:
  - `YingDistribution/Views/Screens/AmethystAnalysis.swift:95-107` - The exact problematic `Consolidated Metrics` row.
  - `YingDistribution/Views/Screens/AmethystAnalysis.swift:155-162` - Equal-width and fixed-height constraints that must remain untouched.
  - `YingDistribution/Views/Screens/VermilionDashboard.swift` - Another consumer set of `CobaltCard`; review for possible regression exposure.

  **Acceptance Criteria**:
  - [ ] The plan uses the shared-component fix only.
  - [ ] `AmethystAnalysis` card row constraints remain unchanged.
  - [ ] Other `CobaltCard` usage remains compatible with shrink-to-fit behavior.

  **QA Scenarios**:
  ```
  Scenario: Consolidated Metrics layout remains unchanged
    Tool: Read
    Preconditions: Task 1 complete
    Steps:
      1. Open `AmethystAnalysis.swift`
      2. Confirm `summaryGrid.distribution = .fillEqually` still exists
      3. Confirm `summaryGrid.heightAnchor.constraint(equalToConstant: 100)` is unchanged
      4. Confirm the metric cards are still configured through `CobaltCard`
    Expected Result: The fix stays inside the shared card component
    Evidence: .sisyphus/evidence/task-2-layout-guardrails.txt

  Scenario: Other CobaltCard consumers remain within scope
    Tool: Grep + Read
    Preconditions: Task 1 complete
    Steps:
      1. Search for `CobaltCard()` instantiations across the app
      2. Review each known consumer for obvious incompatibility with shrink-to-fit values
    Expected Result: No consumer requires separate layout changes for this fix
    Evidence: .sisyphus/evidence/task-2-cobaltcard-audit.txt
  ```

- [x] 3. Build and manually verify the affected metrics on device layouts

  **What to do**:
  - Build the app for iPhone simulator.
  - Launch and navigate to `Amethyst Analysis` → `Consolidated Metrics`.
  - Verify `Expected Value` and `Total Simulations` show their full values without ellipsis on a compact device and a larger device.
  - Capture screenshots/evidence.

  **Must NOT do**:
  - Do not treat build-only verification as sufficient.
  - Do not mark complete without visual confirmation of the two affected values.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: runtime manual QA with concrete UI verification.
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Final wave
  - **Blocked By**: Task 2

  **References**:
  - `YingDistribution/Views/Screens/AmethystAnalysis.swift:214-220` - The exact values to inspect at runtime.
  - `.sisyphus/evidence/` - Save build and screenshot evidence here.

  **Acceptance Criteria**:
  - [ ] Build succeeds on iPhone 15 simulator.
  - [ ] `Expected Value` is fully visible in `Consolidated Metrics` on a compact layout.
  - [ ] `Total Simulations` is fully visible in `Consolidated Metrics` on a compact layout.
  - [ ] The same two cards remain readable and aligned on a larger device layout.
  - [ ] No ellipsis is visible in either affected metric card during QA.

  **QA Scenarios**:
  ```
  Scenario: Compact device renders full values
    Tool: Bash + simulator/manual UI QA
    Preconditions: app builds successfully, simulator available
    Steps:
      1. Run `xcodebuild -project YingDistribution.xcodeproj -scheme YingDistribution -destination 'platform=iOS Simulator,name=iPhone 15' build`
      2. Launch the app in a compact-width simulator if available
      3. Navigate to `Amethyst Analysis`
      4. Inspect the `Consolidated Metrics` section
      5. Confirm `Expected Value` and `Total Simulations` show full text with no `…`
    Expected Result: Both values are fully readable without truncation
    Failure Indicators: ellipsis, clipped digits, overlapping text, or unreadably tiny text
    Evidence: .sisyphus/evidence/task-3-compact-metrics.txt

  Scenario: Larger device remains aligned and readable
    Tool: simulator/manual UI QA
    Preconditions: same build available
    Steps:
      1. Launch the app on a larger simulator device
      2. Navigate to `Amethyst Analysis`
      3. Inspect the same `Consolidated Metrics` row
      4. Confirm the cards still look aligned and the values remain readable
    Expected Result: No regression in card alignment or readability
    Evidence: .sisyphus/evidence/task-3-large-device-metrics.txt
  ```

---

## Final Verification Wave

- [x] F1. **Plan Compliance Audit** — `oracle`
  Confirm the implementation only changes shared `CobaltCard` value-label behavior and preserves exact values, existing layout, and manual-QA evidence scope.

- [x] F2. **Code Quality Review** — `unspecified-high`
  Rebuild the app and inspect the changed file for unnecessary layout edits, formatter changes, or unrelated cleanup.

- [x] F3. **Real Manual QA** — `unspecified-high`
  Re-run the `Consolidated Metrics` check on the target simulators and confirm both affected values remain fully visible with no ellipsis.

- [x] F4. **Scope Fidelity Check** — `deep`
  Verify the fix stayed within the metric-card truncation scope and did not expand into card redesign, typography system changes, or formatting logic changes.

---

## Commit Strategy

- **Suggested grouping**:
  - `fix(ui): prevent consolidated metric values from truncating`

---

## Success Criteria

### Verification Commands
```bash
xcodebuild -project YingDistribution.xcodeproj -scheme YingDistribution -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Final Checklist
- [ ] `Expected Value` no longer truncates in `Consolidated Metrics`
- [ ] `Total Simulations` no longer truncates in `Consolidated Metrics`
- [ ] Exact numeric values are preserved (no abbreviation)
- [ ] Existing card layout remains intact
- [ ] Manual QA evidence captured for compact and larger layouts

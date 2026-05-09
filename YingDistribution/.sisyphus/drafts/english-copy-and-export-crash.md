# Draft: English copy and export crash

## Requirements (confirmed)
- App-visible text should be English only; no Chinese should appear in the app UI.
- Home screen Export button currently crashes when tapped.
- Crash line provided by user: `label.draw(at: CGPoint(x: x + (barWidth - labelSize.width) / 2, y: size.height - margin + 8), withAttributes: attr)`
- Crash reason provided by user: `Thread 1: "-[__NSCFType set]: unrecognized selector sent to instance ..."`

## Technical Decisions
- Pending codebase survey before choosing implementation approach.

## Research Findings
- Pending explore results.

## Open Questions
- Should the English-only requirement cover only visible UI copy, or also exported image/report labels and in-app stored sample content?
- Should terminology remain domain-specific as-is, with only language conversion, or is terminology cleanup also desired?

## Scope Boundaries
- INCLUDE: export crash diagnosis and English-only UI text cleanup planning.
- EXCLUDE: pending confirmation on broader terminology/product naming refactor.

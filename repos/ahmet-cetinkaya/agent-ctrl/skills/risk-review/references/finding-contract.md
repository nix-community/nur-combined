# Finding Contract

A review finding is reportable only when it includes all of:

1. `file:line` or the narrowest stable pointer;
2. severity and affected behavior;
3. a concrete input, state, call path, or failure scenario;
4. reproduction, tool output, code evidence, or a clearly bounded proof;
5. a specific remedy at the owning layer.

## Severity

- **CRITICAL** — will cause bugs, data loss, security exposure, or crashes on the real surface.
- **MAJOR** — significant correctness or quality defect that should be fixed before delivery.
- **MINOR** — improvement worth making but not blocking.
- **NITPICK** — style preference; report only when explicitly requested.

Order findings by severity. Only CRITICAL and MAJOR findings may block a verdict; state per finding whether it blocks. With each verdict include a confidence level (HIGH, MEDIUM, LOW) and what evidence drives it.

Do not report style preference, unsupported hypotheticals, project-wide claims from a narrow sample, or alternatives that merely differ from the chosen design. Introducing a new pattern where the neighboring code already establishes one is a reportable consistency finding; personal preference against an established pattern is not. Keep unresolved questions separate from findings and state what evidence would settle them.

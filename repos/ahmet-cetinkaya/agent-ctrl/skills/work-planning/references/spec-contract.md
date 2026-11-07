# Spec Contract

A spec records **what** the system must do and **why**, never how. It is the upstream artifact of a plan: `/ac:spec` writes it, the user approves it, and `/ac:plan` derives tasks from it. Technology, file layout, and implementation choices belong in the plan.

## Layout

```
specs/<capability>/SPEC.md              # living spec: current truth for one capability
specs/changes/<NNNN>-<slug>/SPEC.md     # change spec: one new feature or one delta
specs/changes/<NNNN>-<slug>/checklists/ # requirements.md quality record and optional domain checklists
specs/changes/<NNNN>-<slug>/{research.md,data-model.md,contracts/}  # design, written by /ac:plan when needed
specs/changes/archive/<NNNN>-<slug>/    # shipped changes, immutable
```

All spec artifacts live under `specs/` at the project root; only work items live under `.agents/work/`.

- `<capability>` is a short kebab-case domain name (`auth`, `billing`, `export`). `changes` is reserved and cannot be a capability name. A brand-new capability is created by the first change that ships to it.
- `<NNNN>` is a four-digit sequence: the highest number found under `specs/changes/` (including `archive/`) plus one. Never reuse a number.
- Spec directories stay outside `.agents/work/`; the executor selects plans by globbing `.agents/work/*/plan.md`.
- The design files beside a spec are the plan's, not the spec's; [design artifacts](design-artifacts.md) defines when each is written.

## Frontmatter

```yaml
---
status: draft
capability: <capability>
plan: # .agents/work/<slug>/plan.md once one exists
supersedes: # optional: <NNNN>/FR-### entries this change replaces
---
```

A plan moved to the archive resolves per the [run-state contract](../../plan-execution/references/run-state.md) archive rule.

Lifecycle values are `draft`, `approved`, `in_progress`, and `shipped`.

- `/ac:spec` writes and revises `draft`.
- Only explicit user approval changes `draft → approved`. Approval covers the intent, not the risky operations a later plan may propose.
- The executor changes `approved → in_progress` when the linked plan starts, and `in_progress → shipped` only after the plan's final verification passes.
- A `shipped` change is merged into its living spec and moved under `archive/`; archived specs are never edited. New behavior is a new change.

## Change spec body

1. **Intent** — the outcome and the reason, in the user's language, three to five sentences.
2. **User stories** — `### US<n> — <title> (Priority: P<n>)`. Each story says why it has that priority, names its independent test (how it could be demonstrated alone), and lists its Given/When/Then scenarios. P1 is the smallest slice that delivers value on its own.
3. **Requirements** — `FR-###` in EARS form (see below). Every requirement must be testable, technology-agnostic, and traceable to a story.
4. **User experience** — always present. Either the single line `none — no user interface`, or: the flow, every visible state (success, empty, loading, error, unauthorized), a link to a fixed version of the design when one exists, and the accessibility expectations. Every listed state is covered by a scenario or an `FR-###`. Never invent visuals; a design link that points at a version still changing is not fixed. A design change after approval is a spec change, not a silent update.
5. **Key entities** — only when the change involves data: each entity, what it represents, its key attributes, identity, and relationships, without storage or schema detail.
6. **Success criteria** — `SC-###`: measurable outcomes an observer can confirm without reading the code.
7. **Edge cases** — empty, invalid, boundary, concurrent, unauthorized, and failure inputs, each with the required behavior.
8. **Assumptions** — defaults adopted instead of asking, so the user can correct them.
9. **Out of scope** — what this change deliberately does not do, plus the record of a declined split (see Size).
10. **Clarifications** — `### Session <YYYY-MM-DD>` with `- Q: … → A: …` lines, appended by later `/ac:spec` runs.
11. **Deviations** — appended by the executor when implementation cannot follow the spec as written: what deviated, why, and the user's decision. Empty until execution.

When the change alters an existing capability, section 3 is split into delta blocks that reference the living spec:

- `### ADDED` — new requirements.
- `### MODIFIED` — the complete revised text of an existing requirement, keeping its ID.
- `### REMOVED` — the ID and a one-line reason.
- `### PRESERVED` — `PB-<n>` statements naming behavior that must keep working after the change. At least two; they become regression criteria.

## Size

One change spec covers one user capability that fits in a single plan. When the intent spans more than one capability, or the spec needs more than ten `FR-###` entries, recommend a split: name each resulting change spec and the order to ship them. When the user keeps it whole, record that under Out of scope as `Split: proposed <spec names>; kept as one — <reason>`.

## Descoping

After approval, a requirement, success criterion, or preserved behavior is never deleted. Descope it only with the user's decision: strike the entry through and append where it went, then record the decision under Deviations.

```markdown
- ~~**FR-004**: WHEN … THE SYSTEM SHALL …~~ → moved to `0012-bulk-export`
- ~~**SC-002**: …~~ → dropped: <reason>
```

A struck-through entry keeps its row in traceability and evidence tables, which cite the move instead of evidence. A security, privacy, or authorization entry cannot be dropped, only moved to another change spec.

## Requirement format

Use EARS patterns with `SHALL`:

| Pattern           | Form                                                     |
| ----------------- | -------------------------------------------------------- |
| Ubiquitous        | `THE SYSTEM SHALL <behavior>`                            |
| Event-driven      | `WHEN <trigger> THE SYSTEM SHALL <behavior>`             |
| State-driven      | `WHILE <state> THE SYSTEM SHALL <behavior>`              |
| Unwanted behavior | `IF <condition> THEN THE SYSTEM SHALL <behavior>`        |
| Optional feature  | `WHERE <feature is present> THE SYSTEM SHALL <behavior>` |

Scenarios under user stories use `Given <state>`, `When <action>`, `Then <observable>`. A requirement without an observable is not finished.

## Uncertainty

Make an informed default and record it under Assumptions rather than stalling. Mark only what a default cannot settle with `[NEEDS CLARIFICATION: <question>]`, at most three per spec, prioritized scope > security and privacy > user experience > technical. A spec with an open marker stays `draft`.

## Living spec merge

On ship, the executor applies the change to `specs/<capability>/SPEC.md`: ADDED requirements are appended, MODIFIED ones replace their prior text, REMOVED ones are deleted, struck-through descoped entries are not carried over, and PRESERVED statements are dropped (they described the unchanged baseline). The living spec keeps the same body sections minus Clarifications and Deviations; checklists stay with the archived change. It adds a `## History` list of `<NNNN>-<slug> — <date>` entries.

## Traceability

The plan derived from a spec carries a **Traceability** table: every `FR-###`, `SC-###`, and `PB-<n>` maps to at least one task and one evidence source. Verification reports every criterion with its evidence; a criterion without evidence blocks `READY`. A descoped entry cites its move instead (see Descoping).

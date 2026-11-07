# `clean-code` composition

- **Target and responsibility:** One always-on rule for readability and clean-code discipline at write time, so fewer findings reach the clean-code review lens.
- **Sources:** Robert C. Martin, _Clean Code_ (naming, functions, comments, formatting, and the smell/heuristic lists); current `risk-review/references/lenses.md`, whose clean-code lens is the read-side counterpart of this rule; current `plan-execution/references/implementation.md` and `agents/worker.md`, minimum change at the owning layer and no adjacent refactor.
- **Behavior taken:** Intent-revealing names, single-purpose functions, top-down control flow, no duplication within the new code, named constants, unswallowed errors, why-only comments, no dead or debug code, local style and toolchain first, and a reviewer-eyed reread of the diff before handover.
- **Merge:** The review lens stays the detector; this rule is the short preventive form loaded on every turn.
- **Provider adaptation:** Language- and tool-neutral; renders unchanged in either platform's guidance.
- **Exclusions:** Numbered heuristic lists, per-language style guides, test-code heuristics (covered by the lens), and any license to refactor beyond the task's scope were excluded; the two size cues kept ("fits on a screen", two nesting levels) are reading thresholds, not lint limits.
- **Attribution:** Original concise synthesis of publicly documented Clean Code principles; no text is reproduced from the book.

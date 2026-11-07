# `risk-review` composition

- **Target and responsibility:** Read-only correctness review with additional lenses selected by concrete risk or explicit request.
- **Sources:** [Everything Claude Code](https://github.com/affaan-m/ECC) `agents/code-reviewer.md`, concrete failure/evidence filtering; [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/security-review/SKILL.md`, security lens; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/shared-skills/skills/review-work/SKILL.md`, intent/constraint/evidence gate.
- **Behavior taken:** Correctness default, selective lenses, surrounding-call inspection, severity ordering, and a strict finding contract.
- **Merge:** Multiple overlapping review skills become one router with lightweight lens and finding references; advisor supplies independent high-risk context.
- **Provider adaptation:** No panel or harness-specific QA/subagent syntax; file pointers and evidence are shared across providers.
- **Exclusions:** Mandatory review for every change, auto-fixes, fixed line/language style, and speculative or preference-only findings were excluded.
- **Attribution:** Original rewrite drawing on [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT) and [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License); no upstream prose is copied verbatim.

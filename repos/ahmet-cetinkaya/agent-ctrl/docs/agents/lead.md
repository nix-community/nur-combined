# `lead` composition

- **Target and responsibility:** Default session owner for direct bounded work, specialist routing, and final evidence.
- **Sources:** [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) Sisyphus agent, bounded direct work, delegation, depth, and verification behavior; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/omo-opencode/src/agents/sisyphus/` prompt family, orchestration and verification sections.
- **Behavior taken:** Per-turn intent gate (a question never inherits implementation authorization), one-question ambiguity rule, three-failure stop-restore-escalate recovery, one-known-file, local and reversible fast path; self-contained delegation; acyclic depth; parent verification; and risk-triggered depth.
- **Merge:** Combines the legacy portable seven-role shape with current OMO orchestration discipline, but uses the shared focused skills as policy.
- **Provider adaptation:** Uses canonical `Task` in source frontmatter; agent-ctrl lowers tool keys for OpenCode. Claude Code alone uses `models.claude: inherit`, preserving the session's selected model; names and prompt prose remain provider-neutral.
- **Exclusions:** Mandatory delegation for every multi-step or UI change, background-task syntax, provider categories, model tiers, and blanket review fan-out were omitted.
- **Attribution:** Original rewrite drawing on [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License); no upstream prose is copied verbatim.

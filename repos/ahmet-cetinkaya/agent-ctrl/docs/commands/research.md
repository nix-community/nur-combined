# `/ac:research` composition

- **Target and responsibility:** Produce a cited existing-solution recommendation without implementation.
- **Sources:** [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) `src/superclaude/commands/research.md`, repo-first/external/evaluate/decide flow; [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/search-first/SKILL.md`, Adopt/Extend/Compose/Build matrix; [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) `src/superclaude/agents/deep-research.md`, source quality and synthesis; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/shared-skills/skills/ulw-research/SKILL.md`, evidence and citation emphasis; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/omo-opencode/src/agents/librarian.ts`, versioned official-source discovery.
- **Behavior taken:** Ordered source search, candidate comparison, citations, caveats, and explicit decision.
- **Merge:** Internal exploration and external research are coordinated through `solution-research`, `explorer`, and `researcher`.
- **Provider adaptation:** No hardcoded MCP, provider call, team, or background-task syntax; local and web evidence are tool-neutral.
- **Exclusions:** Maximum-saturation teams, runtime ledgers, implementation handoff, and stale namespaces were omitted.
- **Attribution:** Original rewrite drawing on [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) (MIT), [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT), and [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License); no upstream prose is copied verbatim.

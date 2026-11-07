# `solution-research` composition

- **Target and responsibility:** Evidence-led decision to adopt, extend, compose, or build.
- **Sources:** [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/search-first/SKILL.md`, triggers, search order, evaluation, and decision outcomes; [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) `src/superclaude/agents/deep-research.md`, source evaluation and synthesis; [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) Librarian agent, installed-version grounding and primary sources; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/omo-opencode/src/agents/librarian.ts`, version and official-document discovery.
- **Behavior taken:** Repo-first search, versioned docs, authoritative external sources, maintained usage, candidate caveats, and citations.
- **Merge:** Search-first and librarian research become one bounded decision method with a separate comparison matrix.
- **Provider adaptation:** MCP-specific channels and provider call syntax are replaced by source classes and common local/web tools.
- **Exclusions:** Silent fallback when a channel is unavailable, implementation, dependency installation, and exhaustive research teams were removed.
- **Attribution:** Original rewrite drawing on [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT), [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) (MIT), and [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License); no upstream prose is copied verbatim.

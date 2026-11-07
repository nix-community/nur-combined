# `explorer` composition

- **Target and responsibility:** Read-only internal search returning concise `file:line` and call-site evidence.
- **Sources:** [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) Explore agent, read-only search and report behavior; [Everything Claude Code](https://github.com/affaan-m/ECC) `agents/code-explorer.md`, “Entry Point Discovery,” “Execution Path Tracing,” and dependencies; [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/iterative-retrieval/SKILL.md`, progressive refinement and stop guidance; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/omo-opencode/src/agents/explore.ts`, repository exploration role.
- **Behavior taken:** Query translation, broad-to-narrow search, definition/caller tracing, evidence pointers, and explicit not-found results.
- **Merge:** Deep legacy exploration is bounded by OMO's fast search role and returned as evidence rather than a generic architecture report.
- **Provider adaptation:** A `tools` allowlist of read and search tools with no shell replaces provider-specific search calls, because Claude Code returns Grep and Glob to a subagent only when its allowlist names them and leaves out Bash; the leaf has no `Task`. Claude Code alone routes this fast lookup role to `haiku` through `models.claude`.
- **Exclusions:** Codegraph dependency, network access, mutation commands, exhaustive surveys, and provider background-task syntax were excluded.
- **Attribution:** Original rewrite drawing on [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License) and [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT); no upstream prose is copied verbatim.

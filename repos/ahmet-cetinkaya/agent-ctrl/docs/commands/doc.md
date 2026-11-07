# `/ac:doc` composition

- **Target and responsibility:** Produce verified, audience-specific documentation for one code/API/feature/flow target.
- **Sources:** [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) `src/superclaude/commands/document.md` and `src/superclaude/agents/technical-writer.md`; current `explorer`, `worker`, and risk-review contracts; prose style via the `technical-writing` skill (see `docs/skills/technical-writing.md`).
- **Behavior taken:** An on-request `explainer` type that renders a plan or spec as a readable HTML view (artifact or git-ignored file) for approval, without changing the source; analyze behavior before writing, choose documentation form, match local style/placement, verify links/examples, and separate chat draft from authorized file edits.
- **Merge:** The old documentation hub becomes a self-contained command; `explorer` establishes truth, `worker` performs bounded edits, `advisor` reviews high-risk/public contracts.
- **Provider adaptation:** Removed `/sc:document`, `/ac:index`, persona, and MCP assumptions.
- **Exclusions:** Repo-wide indexing, generated/vendor doc edits, speculative behavior, publishing, and implicit code changes.
- **Attribution:** Original rewrite drawing on [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) (MIT); no upstream prose is copied verbatim.

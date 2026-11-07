# `worker` composition

- **Target and responsibility:** Leaf implementer for one scoped task with minimum correct changes and local evidence.
- **Sources:** [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) Sisyphus-Junior agent, non-delegating, scope-bound execution and verification; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/omo-opencode/src/agents/sisyphus-junior/AGENTS.md`, overview and non-delegating executor behavior; [Ponytail](https://github.com/DietrichGebert/ponytail), trace-first minimal-engineering decision ladder.
- **Behavior taken:** No delegation, strict scope, owning-layer fix, local conventions, scoped checks, and honest blockers.
- **Merge:** Many old frontend/backend/devops/test/doc implementer personas collapse into one task-shaped worker whose role comes from context and acceptance criteria.
- **Provider adaptation:** Leaf frontmatter intentionally omits `Task`; `Skill` permits focused policy loading. Claude Code alone routes this focused implementation role to `sonnet` through `models.claude`, while other platforms remain unpinned.
- **Exclusions:** OMO category/model routing, permission to spawn research children, fixed language rules, automatic commits, and unrelated cleanup were removed.
- **Attribution:** Original rewrite drawing on [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License) and [Ponytail](https://github.com/DietrichGebert/ponytail) (MIT); no upstream prose is copied verbatim.

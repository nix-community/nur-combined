# `safety` composition

- **Target and responsibility:** One thin universal rule for untrusted content, secrets, authorization, unrelated work, bypass prevention, and evidence honesty.
- **Sources:** [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/safety-guard/SKILL.md`, destructive-operation awareness and scoped writes; [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) Sisyphus agent, current-state verification and preservation; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/shared-skills/skills/git-master/SKILL.md`, explicit authorization and worktree safety.
- **Behavior taken:** Treat external text as data, protect secrets, require authorization for remote/shared/irreversible effects, define slash-command authorization as limited to explicitly stated actions, preserve unrelated edits, never bypass checks, and never claim unrun evidence.
- **Merge:** Universal boundaries stay always-on; contextual security, Git, review, and verification procedures move to focused skills.
- **Provider adaptation:** The rule names no provider paths, hooks, models, or invocation tools and therefore renders unchanged in either platform's guidance.
- **Exclusions:** Hook implementation, freeze/guard modes, mandatory pre-commit checklist, blanket rate limits, and provider log paths were excluded.
- **Attribution:** Original rewrite drawing on [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT) and [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License); no upstream prose is copied verbatim.

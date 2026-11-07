# `readiness-verification` composition

- **Target and responsibility:** Fail-closed requirement fit and project-defined verification with real-surface evidence.
- **Sources:** [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/verification-loop/SKILL.md`, mechanical phases and report; [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/intent-driven-development/SKILL.md`, observable criteria; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/shared-skills/skills/review-work/SKILL.md`, evidence artifacts and inconclusive outcomes.
- **Behavior taken:** Acceptance fit, applicable gates, exact evidence status, user-surface QA, stale-evidence invalidation, persistent-data risk escalation, and three-state readiness, and a persisted evidence record in the run state.
- **Merge:** Old reflection and verification phases become a skill that writes only its evidence record that does not perform code review or fixes.
- **Provider adaptation:** Commands come from each project; no active profile, language command, or provider QA syntax is assumed.
- **Exclusions:** Universal 80% coverage, timed continuous checks, auto-fix, and `READY` with blocked/missing evidence were removed.
- **Attribution:** Original rewrite drawing on [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT) and [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License); no upstream prose is copied verbatim.

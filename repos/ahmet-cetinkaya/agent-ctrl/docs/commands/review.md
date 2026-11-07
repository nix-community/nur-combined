# `/ac:review` composition

- **Target and responsibility:** Read-only review with correctness always active and risk- or user-selected lenses.
- **Sources:** [Everything Claude Code](https://github.com/affaan-m/ECC) `agents/code-reviewer.md`, concrete failure and evidence requirements; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/shared-skills/skills/review-work/SKILL.md`, goal/evidence gate review.
- **Behavior taken:** Target resolution including staged, unstaged, and untracked files; selective lenses; independent high-risk review; severity ordering; evidence-based findings; and a review record (`reports/<stamp>-code-review.md` plus a `code_review` ledger event) in the run state, mirroring the `/ac:verify` evidence record.
- **Merge:** Many review skills and personas become one `risk-review` skill plus a read-only advisor, avoiding a mandatory panel.
- **Provider adaptation:** Area selection is plain command input; no provider-specific subagent or QA invocation is included.
- **Exclusions:** Auto-fix, mandatory multi-select interview, blanket review after every edit, fixed style dogma, and stale follow-up commands were removed.
- **Attribution:** Original rewrite drawing on [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT) and [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License); no upstream prose is copied verbatim.

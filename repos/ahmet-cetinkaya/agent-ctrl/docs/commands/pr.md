# `/ac:pr` composition

- **Target and responsibility:** Preflight, verify, push normally, and create a draft PR; never commit, force, or merge.
- **Sources:** [Everything Claude Code](https://github.com/affaan-m/ECC) `commands/pr.md`, branch/duplicate/template/test preflight and draft creation; [Everything Claude Code](https://github.com/affaan-m/ECC) `skills/git-workflow/SKILL.md`, status, history, commit, and PR safety; current [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) `packages/shared-skills/skills/git-master/SKILL.md`, explicit authorization, full diff, upstream, and conservative history rules.
- **Behavior taken:** Clean committed branch requirement, existing-PR check, all-commit diff, fail-closed verification, normal push, draft PR, URL and CI report; at start, archives finished work items whose PR is merged to `.agents/archive/` (merge state read through `gh`).
- **Merge:** Git safety and PR automation are composed while keeping commit authorization distinct from PR authorization.
- **Provider adaptation:** Uses standard Git and Git-host CLI concepts; no model, agent call, or provider-specific prompt syntax.
- **Exclusions:** Force-with-lease recovery, automatic commits/rebase, marking ready, merge/release/deploy, and continuation after failed or inconclusive verification were excluded.
- **Attribution:** Original rewrite drawing on [Everything Claude Code](https://github.com/affaan-m/ECC) (MIT) and [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (Sustainable Use License); no upstream prose is copied verbatim.

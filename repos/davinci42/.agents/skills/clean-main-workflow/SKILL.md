---
name: clean-main-workflow
description: Maintain clean main-branch history in this NUR repository. Use for commits, PRs, squash merges, branch cleanup and published-history recovery. Not a replacement for package-update validation.
---

# Clean main workflow

Follow `AGENTS.md` and the active assistant's authorization and attribution rules.
Prefer one reviewed commit per PR and squash merges.

## Review and validate

Read the working tree and verify the target repository and base branch before
GitHub operations. Preserve unrelated changes; stage only relevant paths.

```sh
git status --short --branch
git diff
git diff --cached
git log -5 --oneline
git remote -v
git branch -vv
```

Use `gh` for GitHub. Fetch the verified base before comparing history; start new
work from that base, not a previously squash-merged branch. Load
`nur-package-update` for package updates. Run the applicable `just check` or
`just check-all` and `git diff --check` before publication.

## Commit and PR

- Do not commit or push without authorization. A PR request does not authorize
  merging, repository settings changes or rewriting main.
- Follow the commit titles in `AGENTS.md`. Use the assistant's required commit
  procedure and attribution; do not change Git configuration.
- Combine related unpublished follow-ups into one commit. Rewrite published
  commits only when explicitly authorized.
- Review the full diff and commit count since the fetched base. Keep the PR body
  short: purpose, actual validation and relevant compatibility notes. Put release
  notes in the PR, not the package README.
- Push only the authorized topic branch and use explicit repository, base and
  head arguments when creating the PR. Do not enable auto-merge automatically.

## Merge and cleanup

Merge only when requested, after checking the latest head and required checks.
Substitute verified values in these commands:

```sh
gh pr checks PR_NUMBER --repo OWNER/REPO
gh pr merge PR_NUMBER --repo OWNER/REPO --squash --match-head-commit REVIEWED_HEAD_SHA
```

Do not bypass protections. Verify the resulting single-parent commit on the
remote base. Fast-forward local main only when it preserves local work; delete
only the verified merged topic branch with no unpushed follow-ups.

For recovery, prefer a revert PR. Published-history rewrites require explicit
scope, a recovery ref and an exact expected-tip `--force-with-lease`. Stop if the
lease fails or unrelated commits would be lost. Never reset a dirty worktree.

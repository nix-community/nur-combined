# Draft PR Workflow

Before pushing or opening a draft PR:

1. Confirm repository, current branch, base, upstream, remote, and authenticated Git host.
2. Inspect staged, unstaged, and untracked files; require a clean, fully committed branch. Preserve unrelated work.
3. Check whether an open PR already exists for the head branch.
4. Inspect all commits and the full base-to-head diff, not only the latest commit.
5. Run fail-closed readiness verification on the final committed state. Stop on `NOT_READY` or `INCONCLUSIVE`.
6. Discover and follow the repository PR template and contribution rules.
7. Push normally with upstream setup when needed; never force. Create a draft PR with a concise title, summary, and test plan.
8. Return the URL and observed CI state. Do not mark ready, merge, release, or deploy unless explicitly authorized.

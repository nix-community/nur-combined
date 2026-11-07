# History and Rewrite Guidance

## Investigation

Choose evidence by question:

- `git log -S <text>` for commits that change the occurrence count of an exact string.
- `git log -G <regex>` for commits whose diffs touch lines matching a pattern.
- `git blame -L <start>,<end> -- <file>` for who last changed specific lines.
- `git log --follow -- <file>` for history across renames.
- `git show <commit>` for exact commit intent and diff.
- `git bisect` only with deterministic good/bad bounds and an executable pass/fail check.
- `git reflog` for local recovery evidence and recent history movement.

Cite the exact command evidence in the answer: commit hash, subject, file path, and line or diff context. If the evidence is ambiguous, state what remains unproven. Never treat a failed lookup as proof.

## Rewriting

Before any history write, confirm: current branch, dirty state accounted for, upstream and published status known or explicitly unknown, protected-branch policy, the operation matches the user's request, and the recovery path (`rebase --abort`, a reflog hash, or an untouched worktree).

- Never rewrite `main`, `master`, `dev`, release, or protected branches unless the user explicitly named that exact operation.
- If commits may already be pushed, ask before force-pushing; use `--force-with-lease` only for an authorized published rewrite, never plain `--force`.
- If the worktree is dirty, preserve it intentionally first; do not stash-pop over conflicts without checking what changed.
- For fixups, prefer `git commit --fixup=<hash>` followed by an autosquash rebase.
- Resolve conflicts by intent after reading the conflicting files; never choose ours/theirs blindly.
- When a rebase goes wrong, `git rebase --abort` first; reach for reflog only after explaining the recovery path.

After rewriting, run the cheapest relevant check for the affected behavior and show the new branch log from base to HEAD.

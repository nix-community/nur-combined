# Commit Guidance

Gather ground truth before staging anything: `git status --short`, `git diff --stat`, `git diff --staged --stat`, `git branch --show-current`, recent `git log --oneline`, and the upstream via `git rev-parse --abbrev-ref @{upstream}`. A missing upstream or default branch is a fact to report, not a failure to work around.

## Message style

Detect the message style from recent history and use the dominant local pattern, language, and casing. Do not default to Conventional Commits unless the repository already uses them.

Never add a `Co-authored-by:` trailer, an AI attribution trailer, or any automatic generated footer. Preserve an existing trailer only when the user explicitly asks to keep it.

## Atomic grouping

1. Inspect the full diff, not only filenames; separate unrelated dirty work from the requested commit.
2. Group by behavior, module, and revertability. Keep an implementation with its direct tests; keep generated files with the source change that produced them when omitting them would leave the repository inconsistent.
3. Split unrelated features, config, docs, generated artifacts, and test-only changes unless they are inseparable. Prefer multiple commits for unrelated concerns; a single commit is acceptable only for one indivisible behavior or an explicit user request.
4. Stage by path or hunk so each commit contains exactly its group. Never hide failing or unrelated changes inside a broad commit.
5. Before each commit, verify the staged diff proves the group is right; after each commit, verify with `git log -1 --oneline`.

Finish by listing commit hashes, messages, and any remaining uncommitted files, leaving the worktree state explicit.

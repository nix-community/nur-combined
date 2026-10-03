---
name: clean-main-workflow
description: Maintain clean main-branch history in this NUR repository. Use whenever the user asks to commit, create or revise a PR, combine commits, squash merge, explain duplicate commits, configure merge methods, clean merged branches, or undo a published PR. Captures the single-commit PR preference, review evidence, permission boundaries, and safe history recovery. Not a replacement for package-update validation.
---

# Clean main workflow

Aim for one reviewed change set, one PR, and one new non-merge commit on `main`.
Keep the working tree clean without discarding user work. Follow `AGENTS.md`
and the active assistant's commit attribution and authorization requirements.
Load `nur-package-update` as well for package updates and contract reviews.

## 1. Establish scope and authority

- Implementing a change does not authorize committing or publishing it.
- A request to create a PR authorizes the necessary commit and branch push,
  subject to the active assistant's permission rules. It does not authorize
  merging, enabling auto-merge, changing repository settings, or rewriting main.
- Merge only when requested. Change merge settings only when requested.
- Rewrite published history only with explicit authorization for that scope.
  Authorization to rewrite a PR branch is not permission to rewrite main.
- Do not activate services or change consuming configurations for a package PR.
- Keep version-specific release and compatibility notes in the PR, not an
  accumulating README changelog. Leave READMEs unchanged when requested.
  Otherwise correct durable usage documentation if behavior actually changes.

Read status, staged and unstaged diffs, recent history, and applicable memory
files before acting. Preserve unrelated edits and untracked files; stage named
paths, not the entire working tree. Do not automatically stash or reset them.

Use `gh` for GitHub operations. Determine the repository from the user's URL
or verified project context, then check its default branch and clone URL:

```sh
git status --short --branch
git diff
git diff --cached
git log -5 --oneline
git remote -v
git branch -vv
gh repo view OWNER/REPO --json nameWithOwner,defaultBranchRef,sshUrl
gh api repos/OWNER/REPO/git/ref/heads/main --jq '.object.sha'
```

Substitute verified values in all examples. Do not guess URLs, trust the
working-directory name, or assume `origin` targets the requested repository.
This checkout has previously had a remote named `origin` pointing at a different
repository path. If the remote is wrong, use the verified clone URL explicitly;
do not silently edit Git configuration. Fetch the actual target before comparing
history. If its default branch is not `main`, substitute that branch throughout.

Create a descriptive topic branch from the fetched base, not from a previously
squash-merged topic branch. Such a branch still has its original commits, whose
SHAs differ from the squash commit, and can contaminate the next PR. Move only
requested changes onto the new branch; stop if preserving local work is unsafe.

## 2. Prepare one commit

Prefer one commit per requested PR. Include small related follow-ups in that
commit when the user requests them together; do not split version and scheduling
changes after the user asks for one commit. Exclude unrelated work.

### Message conventions

| Change | Title |
| --- | --- |
| Package version update | `fluxdown-server: 0.5.2 -> 0.5.3` |
| New capability | `feat: validate package updates before publication` |
| Bug fix | `fix: preserve settings when an update fails` |
| Internal simplification | `refactor: simplify package update validation` |
| Documentation or tests | `docs: document squash-only merging` / `test: cover failed updates` |
| Routine maintenance | `chore: check upstream releases every four hours` |

Use the actual package attribute and versions, not a Conventional Commit prefix
for a version bump. Write English titles under 72 characters. Explain the outcome
and why it matters, not a list of private identifiers or filenames. Add a short
body for compatibility decisions or an accompanying change that the title does
not cover; wrap it at 72 characters. Preserve the active assistant's required
attribution exactly; do not invent identities or copy stale model metadata.

Before committing, review the staged diff for secrets, unrelated files, generated
output, and simplicity. Run the appropriate checks and `git diff --check`.
Use the active assistant's prescribed commit procedure and message format.

If a local, unpublished commit already exists, amend it to include the follow-up
instead of adding a second commit. Inspect its contents first. For several local
commits, inspect the entire range and consolidate only that topic's work, using
non-interactive Git operations and a clean working tree. Do not reset unrelated
work or rewrite published commits without authorization. After hooks run,
inspect status again; include relevant hook changes and rerun checks as needed.

Verify the final range against the fetched base, not a stale local main:

```sh
git log BASE_SHA..HEAD --oneline
git rev-list --count BASE_SHA..HEAD
git diff BASE_SHA...HEAD --check
git diff BASE_SHA...HEAD
```

The intended count is one. A PR containing one commit can still be squash merged.
Do not create empty commits just to obtain a new PR or a different SHA.

## 3. Validate and publish the PR

For package changes, use the existing `nix-shell --run 'just check PACKAGE'`
entry point and `just contract PACKAGE` for the pinned upstream contract.
Use `just check-all` for shared maintenance changes. Report actual platforms,
executed checks, test counts, and limitations. Foreign-platform hash fetching
is not a build test. Asset readiness is not checksum-manifest verification.
Run VM tests only when requested, and never bypass a failed contract review gate.

Review all commits and the complete diff since base divergence, including new
files. Check that the remote base has not unexpectedly advanced. If it has,
inspect the new range and integrate it safely without introducing merge commits
or silently rewriting a published branch; rerun affected checks.

When the user supplies a reference PR, read it with `gh pr view` and follow its
structure, not its stale versions, validation claims, or warnings. Match the PR
title to the commit's version-update or Conventional Commit style. Explain all
changes in the PR body, including a scheduling change alongside a version bump.

A package PR should use this structure; replace placeholders and mark only checks
that actually ran successfully:

```markdown
Update `PACKAGE` to the reviewed upstream release: VERIFIED_RELEASE_URL

Include any accompanying change and its purpose here.

## Compatibility review

Explain contract differences, upstream source evidence, whether adaptations were
needed, and operational requirements such as restarting matching components.
Omit this section when it has no useful content.

## Checks performed

- [x] Source hashes refreshed for: VERIFIED_PLATFORMS.
- [x] Package built on `TESTED_PLATFORM`.
- [x] Pinned upstream contract regenerated and verified.
- [x] ACTUAL_TEST_COMMAND (ACTUAL_RESULT).
- [x] ACTUAL_LINT_COMMANDS_AND_RESULTS.
- [x] `git diff --check`.

State untested platforms, unrun VM tests, and other verification limits.
```

Push the topic branch with `-u` to the verified repository, then create the PR
with explicit `--repo`, `--base`, and `--head`. Supply the body with a quoted
HEREDOC to prevent shell expansion. Include required assistant attribution.
Do not push main or enable auto-merge as part of creating a PR. Verify the returned
PR's branch, base, commit count, and diff. Stop at the requested publication stage.

## 4. Squash-only merging

`Create a merge commit` retains the topic commit and adds a two-parent merge
commit. Similar titles make these look duplicated, but they are different Git
objects. `Squash and merge` creates one new commit directly on the base, even
when the topic branch contains only one commit. Do not use `--merge` or `--rebase`
for this repository's PR workflow.

Inspect current settings rather than assuming a prior configuration still holds:

```sh
gh api repos/OWNER/REPO --jq '{allow_squash_merge,allow_merge_commit,allow_rebase_merge}'
```

GitHub does not expose a repository-wide default merge-method setting. When the
user asks to enforce squash merging, explain that making it the only allowed
method also removes the other choices, then apply and read back these settings:

```sh
gh api --method PATCH repos/OWNER/REPO \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false
```

Do not alter branch protections, required checks, or squash-message defaults
unless requested. If merging is authorized, inspect the latest PR head, review
requirements, and required checks. Do not use `--admin` to bypass them. Use the
reviewed head SHA as a race guard:

```sh
gh pr checks PR_NUMBER --repo OWNER/REPO
gh pr merge PR_NUMBER --repo OWNER/REPO --squash --match-head-commit REVIEWED_HEAD_SHA
```

Wait for required checks rather than claiming a queued or pending merge succeeded.
If a new commit appears, review and validate it before trying again. If repository
rules block squash merging, report the conflict rather than bypassing the rules.

## 5. Verify main and clean up

After a merge, fetch the verified target and inspect the PR's reported merge SHA.
Confirm the squash commit has exactly one parent, contains the intended changes,
and is reachable from current main. Main may have advanced since the merge; its
tip need not equal this PR's merge SHA. Do not infer success from the title alone.

A clean main means linear new PR history, no accidental topic commits or merge
commits, and a clean local worktree. It does not authorize rewriting old history.

Switch to local main only when doing so preserves all work. Fast-forward it to
the fetched main with `git merge --ff-only FETCHED_MAIN_SHA`. If it diverges,
inspect and report the local-only commits instead of automatically resetting.
Do not run an unqualified pull when its upstream may target another repository.

Delete only this PR's topic branch after verifying the merge and confirming there
are no unpushed follow-ups. Respect explicit branch-retention preferences. A
squashed topic commit is not an ancestor of main, so `git branch -d` may refuse;
verify the squashed content and absence of unique work before using `-D` as part
of authorized cleanup. Never bulk-delete branches or reset a dirty worktree.

Report the PR URL, merge status, validation result, and any unresolved cleanup.
Do not claim main is clean without checking both local status and remote history.

## 6. Recovery is exceptional

A request to explain duplicate-looking commits is read-only, not permission to
remove them. Prefer an ordinary revert PR when undoing published work unless
the user specifically authorizes history rewriting. Distinguish undoing changes
from removing only a merge wrapper; they have different outcomes.

For an explicitly authorized main rollback, identify the exact last-good SHA,
inspect every descendant that would disappear, preserve a local recovery ref,
and explain which changes will be removed. If new unrelated commits would be
lost, stop for scope confirmation. Use the freshly observed remote tip as a lease:

```sh
git push --force-with-lease=refs/heads/main:EXPECTED_REMOTE_SHA \
  VERIFIED_CLONE_URL LAST_GOOD_SHA:refs/heads/main
```

Never use plain `--force`. A lease failure means the remote changed: inspect it,
do not simply substitute the new SHA and retry. Verify the resulting remote SHA
and validate the restored code. Do not delete recovery refs without permission.

A merged GitHub PR cannot be unmerged, reopened, or deleted through ordinary PR
operations. Removing its commits from main does not change its historical
`MERGED` status. State that limitation clearly. To retry, create a fresh topic
branch from the restored base and reuse the desired single commit after reviewing
its diff. Open a new PR, without automatically merging it or creating empty commits.

## Evaluation

Use `evals/evals.json` for sandboxed workflow rehearsals. Never execute its merge,
repository-settings, or force-push scenarios against a live repository. Structural
validation is not an independent behavioral evaluation; label results accurately.

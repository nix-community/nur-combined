---
name: ac:submit-pr
description: "Execute pre-submission analysis and automate Pull Request creation using GitHub CLI"
category: workflow
complexity: standard
mcp-servers: []
personas: []
---

**Goal:** Execute a comprehensive pre-submission analysis and automate the creation of a Pull Request (PR) from the current working branch to the default target branch, using the GitHub CLI (`gh`).

**Instructions for the Agent:**

1. **Environment Setup and Context Identification:**

   - Identify the **Source Branch** (current HEAD) and the **Target Branch** (assume `main` or the configured default branch unless otherwise specified).
   - Verify that the `gh` CLI and `git` tools are available and authenticated.

2. **Pre-Submission Validation Sequence (Fail-Fast):**

   - **Git Status Check:** Execute `git status`. If there are any uncommitted changes (dirty working directory), **ABORT** and report the pending files.
   - **Test Gate:** Execute the standard test command for the repository (e.g., `npm test`, `pytest`, or equivalent). If tests fail, **ABORT** and provide the test failure output.
   - **Branch Naming Policy:** Validate the Source Branch name against the regex `^(feat|fix|docs|style|refactor|perf|test|chore)\/[\w-]+\S$`. If the name does not match, issue a **WARNING** but do not abort.

3. **Analysis and Content Generation:**
   - **Commit Validation:** Review the commits since the last merge/pull from the Target Branch. Check that the commit messages adhere to **Conventional Commits** (e.g., `feat: Add new user service`). Report any non-compliant commits in the final feedback section.
   - **Conflict Check:** Execute a dry-run merge (e.g., using `git merge-tree`) to detect merge conflicts with the Target Branch. If conflicts are found, **ABORT** and list the conflicting file paths.
   - **Draft Title:** Set the PR Title as the message of general branch name.
   - **Draft Description:** Generate a detailed PR description using the following streamlined template. **DO NOT** include a summary or list of modified files:

```markdown
### 🚀 Motivation and Context

[Summarize the feature, fix, or chore based on the commit messages and the branch name.]

### ⚙️ Implementation Details

[Describe the technical approach, key changes, and any relevant considerations.]

### 📋 Checklist for Reviewer

- [ ] Tests passed locally.
- [ ] Commit history is clean and descriptive.
- [ ] Documentation updated (if applicable).
- [ ] Code quality standards were met (e.g., linter passed).

### 🔗 Related [optional]

[List any related issues or PRs, if applicable. Don't add itself pr.]
```

4. **Pull Request Creation (GitHub CLI):**

   - Execute the `gh pr create` command.
   - **Draft:** ALWAYS use the `--draft` flag to create a draft PR. Never create a non-draft PR.
   - **Labels:** Automatically apply the label corresponding to the branch prefix (e.g., `feat/` $\rightarrow$ `enhancement`, `fix/` $\rightarrow$ `bug`).
   - **Assignee:** Assign the PR to the current authenticated GitHub user (`@me`).
   - **Reviewers:** Check for an active `CODEOWNERS` file. If present, assign relevant users listed there. Otherwise, explicitly use the flag `--reviewer @DEFAULT_TEAM_LEAD` (substitute `@DEFAULT_TEAM_LEAD` with an actual username/team).

5. **Feedback and Reporting:**
   - Provide a final report summarizing the entire execution process.
   - If successful, output the final PR link and the Title.
   - If aborted, state the specific reason (e.g., "**Tests Failed**," "**Merge Conflicts Detected**") and provide the relevant error output.

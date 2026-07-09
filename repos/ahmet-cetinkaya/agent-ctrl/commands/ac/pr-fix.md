---
name: ac:pr-fix
description: "Review and fix code review comments from the current branch's Pull Request."
category: workflow
complexity: standard
mcp-servers: []
personas: []
---

Review the most recent code review comments in the Pull Request (PR) associated with the **current Git branch**.
List the comments in reverse chronological order (newest first).

Example: To automatically detect the PR of the current branch and fetch its comments:

```bash
# Get the current PR info (number + repo)
pr_info=$(gh pr view --json number,headRepository --jq '{number: .number, repo: .headRepository.nameWithOwner}')

pr_number=$(echo "$pr_info" | jq -r '.number')
repo=$(echo "$pr_info" | jq -r '.repo')

# Fetch PR comments in reverse chronological order
gh api repos/$repo/pulls/$pr_number/comments --jq 'sort_by(.created_at) | reverse | .[] | {body, path, line, created_at, user}'
```

Step 1: Analysis & Plan

- Identify the specific issues raised (bugs, style violations, performance concerns, or architectural suggestions).
- Summarize the key problems in a structured list.
- Develop a comprehensive action plan, including:
  - Prioritized steps for implementation.
  - Required code changes or refactors.
  - Potential impacts on existing functionality.
  - Estimated time or effort for each fix.
  - Any dependencies or follow-up reviews needed.

Step 2: Implementation

- For each identified issue:
  - Apply the fix in the codebase.
  - Commit the changes with a clear semantic commit message including the module affected, following this format:
    `<type>(<module>): <description>`
    Examples:
    - `fix(auth): correct null pointer in login service`
    - `style(ui): format button component according to lint rules`

- Ensure each commit addresses a single issue for clarity and traceability.

Output:

- First, provide the summary and action plan in markdown format.
- Then, proceed with implementing the fixes and committing them sequentially with the module included in commit messages.
- Before committing, run tests and linters to ensure code quality.
- Finally, format the output as a series of commit messages ready for execution.

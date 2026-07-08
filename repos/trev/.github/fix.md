# Fix Check Failures

You are running in GitHub Actions after the `check` job failed for a pull request.

Inspect the failed logs first:

```sh
gh run view "$GITHUB_RUN_ID" --attempt "$GITHUB_RUN_ATTEMPT" --log-failed
```

Then make the smallest correct change that fixes the failure.

Guidelines:

- Prefer targeted fixes over broad rewrites.
- Keep existing style and repository conventions.
- Run the most relevant checks for the files you changed.
- Do not commit changes.
- Do not push branches.
- Do not create, edit, merge, or close pull requests.
- If the failure cannot be fixed safely, explain the blocker and leave the working tree unchanged where possible.

Finish with a pull request comment for the workflow to post on the failed pull request. The comment should explain what changed and what was verified.

The final response must contain only this exact format, without a code fence or any other text:

BEGIN_PR_COMMENT
<pull request comment>
END_PR_COMMENT

# Fix Check Failures

You are running in GitHub Actions after the `check` job failed for a pull request.

Inspect the failed logs first using the GitHub MCP server. Do not use the `gh` CLI.

If the failed logs cannot be inspected through the GitHub MCP server, explain the blocker and abort without making changes.

Then make the smallest correct change that fixes the failure.

Guidelines:

- Prefer targeted fixes over broad rewrites.
- Keep existing style and repository conventions.
- Do not run checks. Checks run automatically after each commit.
- Do not modify `rev` or `hash` values to fix the failure. If the only apparent fix is changing `rev` or `hash`, explain why a clean fix is not possible and abort without making changes.
- Do not commit changes.
- Do not push branches.
- Do not create, edit, merge, or close pull requests.
- If the failure cannot be fixed safely, explain the blocker and leave the working tree unchanged where possible.

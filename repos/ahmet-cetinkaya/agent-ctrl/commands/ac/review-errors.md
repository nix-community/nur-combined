---
name: ac:review:errors
description: "Orchestrator command for checking error handling and silent failures. Focuses on proper try/catch blocks and logging."
category: review
complexity: standard
mcp-servers: []
personas: [silent-failure-hunter]
---

# Error Handling Review Orchestrator

This command is a category orchestrator triggered by `/ac:review`. Its task is to assign the `silent-failure-hunter` agent to review the provided files specifically for **error handling** issues.

## Scope
- **Silent Failures**: Empty catch blocks, swallowed exceptions
- **Error Logging**: Missing or inadequate error logging context
- **Return Values**: Ignoring error return codes or `Result`/`Option` types
- **Fail-Fast**: Ensuring the system fails predictably rather than entering invalid states

## Workflow
1. Receives target files from `/ac:review`.
2. Passes these files to the `silent-failure-hunter` agent for analysis.
3. Collects the identified findings and **Refactored Code** outputs to fix swallowed errors, returning them to the main `/ac:review` command.

---
name: ac:review:simplify
description: "Orchestrator command for code simplification. Focuses on reducing cyclomatic complexity and improving readability."
category: review
complexity: standard
mcp-servers: []
personas: [code-simplifier]
---

# Code Simplification Review Orchestrator

This command is a category orchestrator triggered by `/ac:review`. Its task is to assign the `code-simplifier` agent to review the provided files specifically for **code simplification and readability**.

## Scope
- **Complexity**: High cyclomatic complexity, deep nesting, overly long functions
- **Readability**: Obscure logic, unnecessary boilerplate, complicated boolean expressions
- **Modernization**: Opportunities to use newer, cleaner language features
- **Refactoring**: Breaking down large functions into smaller, single-purpose utilities

## Workflow
1. Receives target files from `/ac:review`.
2. Passes these files to the `code-simplifier` agent for analysis.
3. Collects the identified findings and **Refactored Code** outputs to simplify the codebase, returning them to the main `/ac:review` command.

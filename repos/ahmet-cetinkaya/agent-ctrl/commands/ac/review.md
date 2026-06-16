---
name: ac:review
description: "Main Code Review router. Identifies files based on the target (git, pr, path) and delegates the review to specialized category sub-orchestrators."
category: review
complexity: advanced
mcp-servers: []
personas: [code-reviewer, system-architect]
---

# `/ac:review` - Comprehensive Code Review Router

This command is the main organizer and router for Code Review processes. Based on the given target (PR, git changes, or a specific directory), it identifies the relevant files and **delegates** the code to specific review categories via sub-agents/orchestrators.

## Usage

```bash
/ac:review [target] [--category <category1> <category2> ...]
```

### 1. Targets
- **`pr`**: Finds and reviews the changes on the active Pull Request.
- **`git`**: Reviews uncommitted or staged `git diff` changes in the local environment.
- **`[path]`**: Reviews all files in the specified directory (e.g., `.`, `src/auth`). If no target is given, it defaults to `git` changes; if there are no changes, it targets `.` (the entire project).

### 2. Categories
By default (`all`), all logical categories are executed. To focus on a specific area, categories can be selected:

- **`clean-code`**: Comprehensive Clean Code principles (naming, comments, G1-G36, etc.)
- **`security`**: Security vulnerabilities and secure coding practices
- **`performance`**: Performance bottlenecks and optimization opportunities
- **`architecture`**: General system architecture, SOLID principles, and design patterns
- **`errors`**: Silent failures and exception handling review
- **`types`**: Type design, encapsulation, and data safety
- **`simplify`**: Simplifying unnecessary complexity to increase code readability

## Orchestration Logic (Workflow)

This command does *not* review the code directly. It only performs the following organization:

1. **Collection:** Gathers the changes and related source codes in the context of the target (PR, Git, or File).
2. **Task Distribution (Delegation):** Launches the relevant expert orchestrators in the background (using `invoke_subagent`) for each requested category.
3. **Consolidation:** Compiles the "Findings" and "Refactored Code" outputs from the sub-categories and presents them to the user as a single, structured **Code Review Report**.

## Triggered Category Orchestrators

Commands triggered in the background:
- `/ac:review:clean-code`
- `/ac:review:security`
- `/ac:review:performance`
- `/ac:review:architecture`
- `/ac:review:errors`
- `/ac:review:types`
- `/ac:review:simplify`

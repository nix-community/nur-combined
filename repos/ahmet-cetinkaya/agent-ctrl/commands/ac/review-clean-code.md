---
name: ac:review:clean-code
description: "Category orchestrator for Clean Code audits. Delegates to specialized experts for each rule category (C1-C5, E1-E2, F1-F4, G1-G36, N1-N7, T1-T9)."
category: review
complexity: advanced
mcp-servers: []
personas: [code-reviewer, code-simplifier, refactoring-expert]
---

# Clean Code Review Orchestrator

This command is a category orchestrator triggered by `/ac:review`. It orchestrates a comprehensive Clean Code audit by delegating tasks to specialized sub-agents. Each sub-agent focuses on a specific rule category derived from Robert C. Martin's "Clean Code" heuristics. 

> Reference: `rules/clean-code.md` for the full catalog of rules.

## Scope and Categories

This orchestrator handles the following specific sub-categories of Clean Code:

| Aspect | Agent | Rules | Focus |
|--------|-------|-------|-------|
| **comments** | `comment-analyzer` | C1-C5 | Comment quality and accuracy |
| **functions** | `code-reviewer` | F1-F4 | Function design (args, output, flags) |
| **naming** | `code-reviewer` | N1-N7 | Naming conventions |
| **architecture** | `code-reviewer` | G1-G10 | Code structure & macro architecture |
| **hygiene** | `code-simplifier` | G11-G20 | Code hygiene & clarity |
| **logic** | `code-reviewer` | G21-G36 | Logic & design decisions |
| **tests** | `pr-test-analyzer` | T1-T9 | Test quality |
| **environments** | `devops-architect` | E1-E2 | Build and test automation |

## Workflow

1. Receives target files and the specific Clean Code aspects to run from the main `/ac:review` command.
2. Identifies the required `review-clean-code-*` expert files (e.g., `review-clean-code-architecture`, `review-clean-code-comments`) based on the requested aspects.
3. Launches the required sub-agents (parallel or sequential) with instructions to cite specific Rule IDs and provide **Refactored Code**.
4. Aggregates all findings into a unified **Clean Code Audit Report**, which is then passed back to the main `/ac:review` router.

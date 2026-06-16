---
name: ac:review:performance
description: "Orchestrator command for performance analysis. Reviews algorithms, time/space complexity, memory leaks, and optimization opportunities."
category: review
complexity: advanced
mcp-servers: []
personas: [performance-reviewer, code-reviewer]
---

# Performance Review Orchestrator

This command is a category orchestrator triggered by `/ac:review`. Its task is to assign the relevant agents (`performance-reviewer`) to review the provided files from a **performance optimization** perspective.

## Scope
- **Algorithmic Efficiency**: Big O complexity, suboptimal loops, inefficient data structures
- **Memory Management**: Memory leaks, excessive object allocation, garbage collection pressure
- **Resource Usage**: Heavy I/O operations, network bottlenecks, database queries
- **Concurrency**: Thread safety, deadlocks, inefficient async/await patterns

## Workflow
1. Receives target files from `/ac:review`.
2. Passes these files to the `performance-reviewer` agent to detect performance bottlenecks.
3. Collects the identified findings and (if possible) **Refactored Code** outputs that resolve the inefficiencies, and returns them to the main `/ac:review` command.

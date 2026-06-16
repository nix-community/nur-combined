---
name: ac:review:types
description: "Orchestrator command for type design analysis. Focuses on encapsulation, invariants, and type safety."
category: review
complexity: advanced
mcp-servers: []
personas: [type-design-analyzer]
---

# Type Design Review Orchestrator

This command is a category orchestrator triggered by `/ac:review`. Its task is to assign the `type-design-analyzer` agent to review the provided files specifically for **type design and encapsulation**.

## Scope
- **Encapsulation**: Leaky abstractions, improper exposure of internal states
- **Invariants**: Invalid states being representable, missing constructor validation
- **Type Safety**: Overuse of primitive types (primitive obsession), missing domain types
- **Immutability**: Mutable states where immutable structures would be safer

## Workflow
1. Receives target files from `/ac:review`.
2. Passes these files to the `type-design-analyzer` agent for analysis.
3. Collects the identified findings and **Refactored Code** outputs to fix type issues, returning them to the main `/ac:review` command.

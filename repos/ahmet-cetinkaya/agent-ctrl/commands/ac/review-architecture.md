---
name: ac:review:architecture
description: "Orchestrator command for high-level system architecture review. Focuses on SOLID principles, design patterns, and module coupling."
category: review
complexity: advanced
mcp-servers: []
personas: [system-architect, code-reviewer]
---

# Architecture Review Orchestrator

This command is a category orchestrator triggered by `/ac:review`. Its task is to assign the relevant agents (`system-architect`) to review the provided files from a **system architecture** perspective.

> Note: This focuses on macro-level architecture (components, APIs, dependencies), distinct from the micro-level structural rules (G1-G10) covered in `ac:review:clean-code:architecture`.

## Scope
- **Design Patterns**: Correct application of design patterns, MVC/MVVM/ECS separation
- **Coupling & Cohesion**: Dependency injection, module boundaries, Law of Demeter
- **SOLID Principles**: Single Responsibility, Open-Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **API Design**: Interface clarity, encapsulation, contract validation

## Workflow
1. Receives target files from `/ac:review`.
2. Passes these files to the `system-architect` agent to review structural integrity and dependencies.
3. Collects the identified findings and architectural improvement suggestions, returning them to the main `/ac:review` command.

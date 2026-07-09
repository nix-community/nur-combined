---
name: review-architecture
description: Review code from a high-level system architecture perspective — SOLID principles, design patterns, module coupling, and API design. Use when auditing structural integrity, dependencies, or component boundaries. Invoked by /ac:review.
metadata:
  origin: ECC
---

# Architecture Review

Audit the provided files for **macro-level system architecture**. This focuses on
components, APIs, and dependencies — distinct from the micro-level structural rules
(G1-G10) covered by the `review-clean-code` skill's `architecture` aspect.

**Role:** You are an expert System Architect. Review structural integrity, dependencies,
and design discipline.

## Scope

- **Design Patterns**: Correct application of design patterns, MVC/MVVM/ECS separation.
- **Coupling & Cohesion**: Dependency injection, module boundaries, Law of Demeter.
- **SOLID Principles**: Single Responsibility, Open-Closed, Liskov Substitution, Interface
  Segregation, Dependency Inversion.
- **API Design**: Interface clarity, encapsulation, contract validation.

## Workflow

1. Receive the target files (from `/ac:review` or directly).
2. Review structural integrity and dependencies against the scope above.
3. Produce **Findings** (cite the principle violated) and concrete architectural
   improvement suggestions.

## Output

A structured findings list. For each finding: the affected file/region, the principle
violated, and the recommended structural change. Where a fix is mechanical, include
refactored code; where it is a larger redesign, describe the target shape.

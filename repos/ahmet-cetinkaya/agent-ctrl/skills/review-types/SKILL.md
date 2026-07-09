---
name: review-types
description: Review type design — encapsulation, invariants, type safety, and immutability. Use when auditing leaky abstractions, primitive obsession, or representable invalid states. Invoked by /ac:review.
metadata:
  origin: ECC
---

# Type Design Review

Audit the provided files for **type design and encapsulation**.

**Role:** You are an expert in type-driven design. Make illegal states unrepresentable.

## Scope

- **Encapsulation**: Leaky abstractions, improper exposure of internal state.
- **Invariants**: Invalid states being representable, missing constructor validation.
- **Type Safety**: Overuse of primitive types (primitive obsession), missing domain types.
- **Immutability**: Mutable state where immutable structures would be safer.

## Workflow

1. Receive the target files (from `/ac:review` or directly).
2. Analyze how types encode (or fail to encode) the domain's invariants.
3. Produce **Findings** and **Refactored Code** that fixes the type issues — introduce
   domain types, tighten constructors, push validation to the boundary.

## Output

A structured findings list. For each finding: the weak type, the invariant it fails to
enforce, and the refactored type design.

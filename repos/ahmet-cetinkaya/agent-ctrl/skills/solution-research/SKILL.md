---
name: solution-research
description: Research whether to adopt, extend, compose, or build a solution using repository and authoritative sources. Use before adding dependencies, integrations, utilities, or unfamiliar APIs; do not use for internal code lookup alone or to implement the recommendation.
---

# Solution Research

## Trigger

Use when a change may already be solved by local code, an installed dependency, a platform feature, or a maintained external project, or when library/API behavior must be confirmed.

## Non-trigger

Do not activate for a simple internal symbol search, implementation of an already-decided design, a debugging loop, or an uncited opinion request.

## Source Order

1. Current repository patterns and installed versions.
2. Vendored source, type definitions, lockfiles, and versioned documentation.
3. Official documentation, changelogs, release notes, and source repositories.
4. Maintained open-source usage when primary documentation is insufficient.

Compare candidates with [the decision matrix](references/decision-matrix.md). Return a cited `Adopt`, `Extend`, `Compose`, or `Build` recommendation, including version fit, maintenance, license, dependency cost, limitations, and confidence. Distinguish documented fact, code observation, and inference. Do not implement or install anything unless separately authorized.

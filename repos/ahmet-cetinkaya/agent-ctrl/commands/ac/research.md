---
name: ac:research
description: Research existing tools, libraries, and patterns before writing code. Search-first; outputs an Adopt/Extend/Compose/Build recommendation with citations.
---

# `/ac:research` — Research Before You Code

Never write custom code for a solved problem. This flow searches the repository, then the ecosystem, evaluates candidates, and returns an explicit decision.

## Usage

```
/ac:research <need or feature description>
```

## Workflow

Activate `solution-research` and route the question to `researcher`; use `explorer` first for in-repo candidates.

1. **Repo first** — search the current codebase for an existing implementation or near-miss that could be extended. Delegate to `explorer` for symbols, call sites, and impact of extending an existing candidate.
2. **Pin versions** — anchor everything to the versions in the manifest/lockfile, not the latest release.
3. **External search** — package registries, official docs, changelogs, source repositories, and maintained real-world usage. Primary sources outrank blog posts and aggregators.
4. **Evaluate** — functionality fit, maintenance and community health, documentation quality, license compatibility, dependency weight, and security posture.
5. **Cross-check** — verify surprising claims against a second source; report contradictions instead of silently picking a side.

## Output

A short recommendation:

- **Decision** — `Adopt`, `Extend`, `Compose`, or `Build`, with the chosen tool/approach and why.
- **Evidence** — links for external claims, `path:line` for local ones, version limits.
- **Caveats** — license/maintenance concerns, migration cost, confidence, and gaps.

## Next Step

Close the turn by naming the single best next command for the decision you reached:

- `Adopt` / `Compose` and the integration is multi-step → `/ac:plan <request>`
- `Extend` / `Build` with a clear, small scope → `/ac:run <request>`
- Decision still contested or evidence insufficient → state what evidence is missing and stop

Name exactly one recommendation. Never chain commands automatically.

## Boundaries

- Read-only: no implementation, no installs, no edits.
- If authoritative evidence is missing, say so rather than inventing it.
- Hand the chosen approach to `/ac:plan` or direct execution — not this command.

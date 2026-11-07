# Decision Matrix

Score evidence qualitatively rather than inventing false precision.

| Decision | Use when | Required evidence |
| --- | --- | --- |
| Adopt | One maintained option fits the need and project constraints directly | Version/API fit, maintenance, license, dependency and operational cost |
| Extend | An existing local or installed solution owns most of the behavior | Extension seam, affected callers, compatibility and test surface |
| Compose | A small combination of established capabilities is clearer than one large dependency or custom system | Boundary between parts, failure handling, integration cost |
| Build | No suitable maintained solution exists, or constraints make external options unacceptable | Search coverage, rejected alternatives, minimum custom scope and maintenance burden |

## Evidence discipline

- Resolve the entity first: when a name could match several products, versions, or forks, settle which one before researching its capabilities; an unresolved identity must never become a premise.
- Verify against the installed version, not the latest documentation; lockfiles and vendored types outrank marketing pages and tutorials.
- Prefer primary sources: official docs, changelogs, and the project's own source over aggregated blog posts. Run a brief counter-search for known limitations, deprecations, or migration pain before recommending adoption.
- A claim that materially drives the recommendation needs either a primary-source citation or a local observation (type signature, vendored code, or a small executed check where already authorized).

Report: question, sources with links or local paths, candidate comparison, decision, caveats, and confidence (HIGH, MEDIUM, LOW). Distinguish documented fact, code observation, and inference. Missing or contradictory authoritative evidence must remain visible, not smoothed over.

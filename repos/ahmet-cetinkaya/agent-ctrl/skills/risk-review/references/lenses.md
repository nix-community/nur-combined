# Review Lenses

- **Correctness** — always active: requirements, state transitions, boundaries, failure behavior, concurrency, compatibility, and regressions.
- **Security** — trust boundaries, authn/authz, input, secrets, sensitive data, injection, dependencies, and abuse paths.
- **Architecture** — ownership, coupling, public contracts, migration path, and reversibility.
- **Performance** — demonstrated hot paths, algorithmic growth, queries, allocations, network calls, contention, and resource cleanup.
- **Errors** — propagation, recovery, partial state, observability, retries, and user-safe messages.
- **Types** — contract accuracy, unsafe assertions or suppression, nullability, serialization, and generated boundaries.
- **Tests** — meaningful regression coverage, failure and edge paths, flakiness, and missing integration or real-surface proof.
- **Simplify** — unnecessary abstraction, duplication, dependency, indirection, or code that can be removed without reducing required behavior.
- **Clean code** — what the `clean-code` rule should have prevented: names that need decoding, functions doing more than one thing, nested or inverted control flow, duplication, magic values, swallowed errors, what-comments, dead or debug code, and test code with the same faults.

Choose lenses from concrete risk, not language dogma or a mandatory panel.

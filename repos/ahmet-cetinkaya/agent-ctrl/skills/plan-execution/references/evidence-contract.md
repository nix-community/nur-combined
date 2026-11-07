# Evidence Contract

Record each check as one of:

- `PASS` — the command or tool ran against the relevant current state and produced the expected observable.
- `FAIL` — it ran and the observable did not satisfy the criterion.
- `BLOCKED` — it could not run because of a named dependency, permission, service, or environment limitation.
- `NOT_APPLICABLE` — the gate does not apply, with a concrete reason.

For every `PASS`, state the exact command or tool, scope, and observable result. For other statuses, include the failure output or reason and its effect on readiness. Persist each recorded check as a `check` event in the [run state](run-state.md) ledger, with captured output under its `evidence/` directory.

Reuse evidence only while its scope still covers unchanged code, dependencies, configuration, and environment. A worker's summary, a dry run where real execution is required, a skipped command, or a stale result is not proof.

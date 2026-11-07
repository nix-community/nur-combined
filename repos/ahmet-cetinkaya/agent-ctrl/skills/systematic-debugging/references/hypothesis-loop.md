# Hypothesis Loop

Runtime truth beats code reading: every claim about why the bug happens must come from observed state, never from a plausible story built by reading code.

Maintain a compact ledger:

| Hypothesis | Evidence for/against | Prediction | Test | Result | Status |
| ---------- | -------------------- | ---------- | ---- | ------ | ------ |

A good test changes one variable and distinguishes at least two candidate causes. Record actual values, traces, failing assertions, or logs rather than “looks wrong.” Invalidate failed hypotheses explicitly so they cannot be retried in disguise.

Before editing, state the causal chain from trigger to first invalid state to symptom. After editing, rerun the original reproduction first, then the nearest regression and integration checks. If the system swallows errors, that swallowing is often the bug itself: make failures loud temporarily and restore at cleanup. Watch for success-shaped failures — a response that reports `ok`/HTTP 200 while a sub-field carries an error token, empty payloads, or zero usage counters.

## Intermittent failures

Intermittence itself is evidence; capture the failure signature with cheap reruns before hypothesizing: the same scope again, the failing test in isolation, the full scope on a quiet machine, and a shuffled order with the seed recorded.

| Signature | Dominant hypothesis | Move |
| --- | --- | --- |
| Same test fails intermittently everywhere | Real race or async test bug (fixed sleeps, unawaited promises) | Reproduce deterministically via completion events or an injected clock |
| Different test each run; isolation and quiet machine green | Environment contention: shared tmp roots, fixed ports, shared containers or caches between concurrent runs | Fix the test infrastructure — namespace every suite-global resource per run |
| Same test only in full suite; isolation green | Test-order dependence or fixture leak | Bisect with the shuffle seed; fix the leaking teardown |
| Fails only in CI | Resource ceilings, parallelism defaults, container clock | Reproduce locally under constraint; raise the signal, not the sleep |

Never fix a flake with retry wrappers, enlarged sleeps, quarantining, or deleting the test; each buries a bug report. A classified but unfixed flake is a finding to report.

## Cleanup

Remove temporary logging, fixtures, generated captures, injected diagnostics, and debug-only configuration unless they are intentional test assets. Leave the worktree state explicit in the final report.

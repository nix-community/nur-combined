# realm-node-attest

This package supplies the standard SPIRE `http_fqdn` NodeAttestor plugins and an
independent HTTP proof responder. HTTP FQDN is the sole Realm enrollment method.
There is no token generator, installer, or fallback.

| Executable | Role |
| --- | --- |
| `realm-node-attest-agent` | Sign a session challenge and publish its proof through the local Unix API |
| `realm-node-attest-server` | Check exact node policy and pinned HTTP proofs before SPIRE issues an Agent SVID |
| `realm-node-attest-responder` | Serve proofs and accept root-authorized local updates |

The responder supports systemd socket activation with `control` and one or both
of the `http4` and `http6` descriptor names. The module supplies these sockets and
runs the responder without root privileges.

Read [the protocol guide](../../docs/realm-http-attestation.md) and
[the migration runbook](../../docs/realm-deployment.md). Cluster policy pins each
node FQDN to its registry mesh IP. Verification bypasses DNS and hosts files,
then dials only configured literal addresses. The reusable module also accepts
private unicast addresses on an explicitly trusted path.

Plain HTTP needs an independently trusted transport. Neither a nonce nor a
signature under a newly supplied key establishes trust in an untrusted endpoint.
Agents still authenticate the SPIRE Server with a pretrusted public CA bundle.

Read [the metrics reference](METRICS.md) for optional loopback HTTP listeners,
metric labels, success semantics, and safe stderr events.

The package check runs `go test ./...`. Tests cover pinned routing, key
substitution, replay, redirect denial, expiry, peer credentials, bounds, and
stream cleanup. The VM fixtures use synthetic addresses and real SPIRE processes.

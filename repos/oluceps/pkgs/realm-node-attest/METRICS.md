# HTTP attestation metrics and events

Each native plugin and the responder can expose a separate HTTP metrics endpoint.
Metrics use the standard library and Prometheus text format 0.0.4.
The package adds no Go dependencies.

## Configuration

`AgentConfig` and `ServerConfig` accept one new JSON field:

| Field | Type | Default | Effect |
| --- | --- | --- | --- |
| `metrics_address` | string | `""` | Literal loopback IP and port. Empty disables the listener. |

All existing fields keep their meanings. The agent still requires `fqdn`,
`trust_domain`, and `control_socket`. The server still requires `trust_domain`,
`nodes`, `port`, and `trust_http_transport: true`.

Add this field to the agent JSON:

```json
"metrics_address": "127.0.0.1:18491"
```

Add this field to the server JSON:

```json
"metrics_address": "127.0.0.1:18492"
```

The responder accepts a new flag:

```sh
--metrics-address 127.0.0.1:18493
```

The flag defaults to empty. These three ports are suggested assignments.
The code does not assign them by default.

The listener accepts literal IPv4 or IPv6 loopback addresses, such as
`127.0.0.1:18491` or `[::1]:18491`. It rejects wildcard addresses, nonloopback
addresses, hostnames, IPv4-mapped IPv6, and address zones. Port zero requests
an ephemeral port and is useful in tests.

Only `GET /metrics` serves metrics. The listener uses its own HTTP mux.
It limits concurrent connections to 16 and request headers to 8192 bytes.
The header read timeout is two seconds. The read, write, and idle timeouts
are five seconds.

Repeated `Configure` calls retain counters and timestamps. The same address
retains the same listener. A changed address must bind before it replaces
the previous listener. A failed configuration retains the previous configuration.
An empty address closes the listener. Plugin `Close` releases the listener,
and each executable calls it when the SDK returns. A Configure RPC context
cannot own the listener because that context ends after the RPC.

The responder closes its metrics listener when `RunResponder` returns,
including context cancellation. Its existing systemd socket contract stays
`control` plus `http4`, `http6`, or the two HTTP sockets. The metrics listener
opens separately and does not add an activation descriptor.

## Metric schema

| Metric | Type | Labels | Meaning |
| --- | --- | --- | --- |
| `realm_http_attestation_total` | counter | `component,node,outcome,stage,reason` | Local agent submissions or failed/skipped streams, completed server streams, and responder requests |
| `realm_http_attestation_duration_seconds` | histogram | `component,node,outcome` | Time to successful agent submission. Otherwise, duration of the completed operation, including cleanup |
| `realm_http_attestation_last_success_timestamp_seconds` | gauge | `component,node` | Unix time of the last local proof success. Zero means none in this process. |
| `realm_http_attestation_pending` | gauge | `component,node` | Active agent streams, reserved server attempts, or stored responder proofs |
| `realm_http_attestation_capacity` | gauge | `component` | 32 pending attempts per server generation, or four stored responder proofs |
| `realm_http_attestation_rejections_total` | counter | `component,node,stage,reason` | Capacity or verified proof quota rejections |
| `realm_http_responder_proofs_total` | counter | `component,node,action` | Accepted publishes, actual deletes, or expired stored proofs |

`component` is `agent`, `server`, or `responder`. On the server, `node` is the
registered key in `ServerConfig.nodes`. On the agent and responder, `node`
is the configured FQDN. Unknown claims and malformed requests use `unknown`.
A caller cannot add a node label. A configured node label identifies policy,
not an authenticated caller.

Node history includes names from successful configurations in this process.
A removed node retains its series. Active streams keep their configuration
snapshot. Server pending gauges include attempts from previous generations
until those attempts close. The capacity gauge describes each generation,
so pending totals can exceed 32 during a configuration change.
The agent has no fixed capacity gauge.

`outcome` is `success`, `failure`, or `skipped`. Counters and histograms create
series at agent submission or when other operations finish. Registered nodes
have initial zero timestamps and pending gauges. All values reset when the process restarts.
The histogram exports `_bucket`, `_sum`, and `_count`. Its finite bucket
bounds in seconds are `0.01, 0.05, 0.1, 0.5, 1, 2.5, 5, 10, 30, 60, 120`.
It also exports the cumulative `+Inf` bucket.

`realm_http_attestation_rejections_total` counts only `capacity` and
`rate_limit` failures. Other failures remain in `realm_http_attestation_total`.
Responder proof actions are `published`, `deleted`, and `expired`.
A replacement publish counts as a publish without adding a pending proof.
A delete of an absent proof returns success without adding a delete action.
Expiry decrements pending once per removed proof.

## Success semantics

| Component | Successful local outcome | Timestamp update |
| --- | --- | --- |
| Agent | The agent publishes its proof and the ready response send succeeds | `response / proof_submitted` |
| Server | Proof verification and quota checks pass, the result has an agent ID, and the attributes send succeeds | `attributes / attributes_sent` |
| Responder public endpoint | The handler writes the full stored proof without a write error | `public / proof_served` |
| Responder control endpoint | The handler accepts a publish or delete | No timestamp update |

Agent success describes local proof submission only. It does not establish server
verification, Core acceptance, or SVID issuance. Core can cancel `AidAttestation`
after it consumes the ready response. Later EOF, cancellation, or other stream
errors do not revise the local submission result. The handler still waits for
Core to close the stream and keeps the proof until then. Existing RPC error
returns stay unchanged. Cancellation before successful submission remains a
failure. Publish failures and response send failures also remain failures.
Submission success requires a live context when the response send starts.
A prior cancellation remains a failure even if the transport returns no send error.

For the agent, histogram `_count{outcome="success"}` counts successful local
submissions, even when the RPC later returns cancellation. Each submission
adds one sample and one success event. Its duration stops when the response
send succeeds, before the remaining stream wait and cleanup. The success
timestamp also updates at submission. Pending still counts the stream until
it closes. No second outcome or duration sample counts its later cancellation.

EOF before an agent challenge produces `skipped / challenge / no_challenge`.
It keeps the existing clean stream exit but cannot increment success.

Server success describes the NodeAttestor plugin result. It does not assert
that SPIRE accepts the attributes or issues an SVID. A proof can pass
verification but fail the quota check or attributes send. Such an operation
counts as a failure and does not update the server success timestamp.
The existing quota charges after verification, before the attributes send.
It therefore limits verified proofs, not issued credentials.

A responder proof read does not establish successful node enrollment.
Control success also describes only a local proof operation. The responder
cannot observe the server verification result or credential issuance.
The HTTP handler can detect local write errors, but it cannot confirm that
a remote client received or accepted the proof.

## Fixed stages and reasons

Stages are `start`, `payload`, `challenge`, `publish`, `response`, `fetch`,
`verify`, `quota`, `attributes`, `public`, and `control`.

| Area | Reasons |
| --- | --- |
| Configuration or stream start | `not_configured`, `internal`, `capacity` |
| Payload | `invalid_payload`, `unknown_node`, `invalid_key` |
| Stream | `stream_error`, `canceled`, `deadline`, `no_challenge` |
| Agent proof | `invalid_challenge`, `publish_failed`, `proof_submitted` |
| Server proof | `invalid_response`, `expired`, `endpoint_failed`, `invalid_proof`, `session_ended`, `rate_limit` |
| Attributes | `invalid_result`, `attributes_sent` |
| Responder | `method`, `invalid_request`, `not_found`, `peer_denied`, `invalid_size`, `proof_served`, `proof_published`, `proof_deleted`, `write_failed` |

These reasons describe fixed operation boundaries. They do not expose raw
error text or individual cryptographic errors.

## Structured events

Each completed operation emits one JSON event to stderr. The event uses the
SDK logger envelope: `@timestamp`, `@level`, and `@message`. The message is
`realm_http_attestation`. Fields are `component`, `node`, `outcome`, `stage`,
`reason`, and `duration_seconds`, with the same bounds as the metrics.
Failures use level `warn`. Success and skipped operations use level `info`.
The responder executable emits a fixed `realm_http_responder` error event
if its run function fails. Its reason is `responder_failed` and stage is `run`.

Events continue when the metrics listener is disabled. Native plugin stdout
remains reserved for the SDK protocol. Events contain no proofs, keys,
nonce or challenge IDs, caller-supplied unknown node names, tokens, request
paths, endpoint URLs, or raw error strings. HTTP servers discard default
error logs because those logs can contain request data.

## Validation

Tests exercise real proof verification, attributes send failure, quota and
capacity rejection, early EOF, label bounds, concurrent scrapes, and registry
updates. A test through the SDK RPC path cancels before the challenge and after
a real proof publish and ready response. It checks local submission counts,
histogram samples, events, retained RPC errors, and proof cleanup. Another test
cancels before the response send when the transport returns no send error.
Listener tests exercise configuration replacement, failed binding,
disable, re-enable, and close. A child process uses the existing two-descriptor
activation contract, serves metrics separately, and releases its metrics port
on context cancellation.

```sh
go test ./...
go test -race ./...
go vet ./...
```

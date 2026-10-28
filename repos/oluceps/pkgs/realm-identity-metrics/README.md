`realm-identity-metrics` exports public certificate metadata for its own canary, configured SVID holders, and an explicit cohort of SPIRE agents.
The daemon also tests whether the configured pinned bundle trusts the current SPIRE Server certificate.

Run the daemon with a public JSON configuration:

```console
realm-identity-metrics validate --config /etc/realm-identity-metrics.json
realm-identity-metrics serve --config /etc/realm-identity-metrics.json
```

The `serve` argument is optional. `validate` checks the configuration without a connection to SPIRE.
The HTTP listener starts before collection. A failed or pending Workload API request cannot block `/metrics`.
`GET /metrics` returns Prometheus text with HTTP 200, including collector status during failures.
`GET /healthz` returns 200 only when all enabled collectors have current, successful results. It returns 503 before collection or after failure.

The minimum configuration is:

```json
{
  "node": "nodens",
  "trust_domain": "nyaw.xyz"
}
```

| JSON field | Requirement or default |
| --- | --- |
| `node` | Required canonical node name. Lowercase DNS labels, at most 63 characters in total. |
| `trust_domain` | Required canonical SPIFFE trust domain, such as `nyaw.xyz`. |
| `listen_address` | `127.0.0.1:18494`. An explicit loopback IP and a port are required. IPv6 loopback is supported. |
| `bundle_path` | `/var/lib/realm-spire/trust-bundle.pem`. Absolute path to the pinned public PEM bundle. |
| `server_address` | `eihort.nyaw.xyz:8081`. A logical FQDN and port are supported. |
| `workload_socket` | `/run/spire/agent/public/api.sock`. Absolute path to the local Workload API socket. |
| `server_admin_socket` | Optional absolute path. Requires `node` equal to `eihort`, an absolute binary path, and an explicit cohort. |
| `spire_server_binary` | Optional trusted absolute path to `spire-server`. Required with the admin socket. No PATH search or shell occurs. |
| `nodes` | Optional list of distinct canonical node names from the registered `http_fqdn` cohort. Required for admin collection. Maximum 128 nodes. |
| `systemctl_binary` | Trusted absolute path to `systemctl`. Required when `workloads` has targets. |
| `workloads` | Optional list of up to 512 targets. Each target has exactly the fields `unit`, `identity`, `address`, and `source`. |

Unknown fields, extra JSON values, relative paths, and non-loopback listeners fail configuration validation.
The parent must supply a trusted configuration file and binary. The package does not change their ownership or access rights.

For Eihort, add these fields to its configuration:

```json
{
  "node": "eihort",
  "trust_domain": "nyaw.xyz",
  "server_admin_socket": "/run/spire/server/private/api.sock",
  "spire_server_binary": "/nix/store/REPLACE-WITH-SPIRE-PACKAGE/bin/spire-server",
  "nodes": ["eihort", "nodens"]
}
```

The parent registers only `spiffe://<trust_domain>/observer/identity/<node>` for this daemon.
Use both exact selectors: `systemd:id:realm-identity-metrics.service` and `unix:user:root`.
The unit runs as `root:realm-proxies`. Only Eihort needs `CAP_DAC_OVERRIDE` for its local admin socket.
The parent controls the unit, Nix wiring, dashboards, and deployment.
The parent also controls the independent WireGuard socket proxy and its Hastur/Eihort source restrictions.
The daemon accepts only a loopback listener. It has no HTTP route for the admin socket.

The canary collector uses go-spiffe Workload API calls with a deadline.
It selects only its exact canary ID, even if the API response contains other identities.
The canary collector exports only its own certificate expiry. Configured holder observations use the interfaces below.
The rotation timestamp records when this process observes a certificate change.
It is absent before the first observed change and resets after a restart. Polls can miss intermediate rotations.
The certificate start time is a separate metric.

The canary key and bundle come from the same bounded Workload API response.
Only its selected observer SVID enters the status client. Other SVIDs in that response do not enter client authentication.

Configure one observation target per holder process:

```json
{
  "node": "nodens",
  "trust_domain": "nyaw.xyz",
  "systemctl_binary": "/nix/store/REPLACE-WITH-SYSTEMD-PACKAGE/bin/systemctl",
  "workloads": [
    {
      "unit": "realm-egress-example-route.service",
      "identity": "spiffe://nyaw.xyz/service/example",
      "address": "127.0.0.1:28001",
      "source": "ghostunnel_status_watch"
    },
    {
      "unit": "realm-observability.service",
      "identity": "spiffe://nyaw.xyz/service/observability",
      "address": "127.0.0.1:18499",
      "source": "caddy_loaded"
    },
    {
      "unit": "realm-internet.service",
      "identity": "spiffe://nyaw.xyz/service/internet",
      "address": "127.0.0.1:19329",
      "source": "envoy_loaded"
    }
  ]
}
```

Targets require distinct `.service` unit names and distinct listener addresses. Several units can share one SPIFFE ID.
Unit names have a 255-byte limit. Identities have a 2048-byte limit and must use the configured trust domain.
Addresses contain only a literal loopback IP and a port. Schemes, paths, queries, and DNS names fail validation.
The source enum has only the three values in this example. The parent must use the actual registered identity for each unit.

| Source | Fixed request | Observation |
| --- | --- | --- |
| `ghostunnel_status_watch` | HTTPS GET `/_metrics/prometheus`, HTTP 200 | The status listener's separate Workload API watch. It does not prove that the business TLS source loaded the certificate. |
| `caddy_loaded` | HTTPS GET `/`, HTTP 204 | The dedicated listener must use Caddy's actual existing SVID source. |
| `envoy_loaded` | HTTP GET `/certs`, HTTP 200 | Public certificate metadata from the local Envoy admin listener. |

TLS targets use TLS 1.3 and the observer's own SVID and Workload API bundle.
The client checks the server chain, certificate times, and exact configured SPIFFE URI. It applies no DNS/IP hostname check to URI-only SVIDs.
Ghostunnel's Workload API mode accepts a valid SPIFFE client with `AuthorizeAny`. The Caddy listener must authorize only the observer ID.
The exporter never requests `/_status`, follows redirects, or dials a business backend. It uses no environment proxy.
Each HTTP response has a 1 MiB body limit and a 16 KiB header limit.
The parent supplies unique Ghostunnel status ports in the host network namespace and the Caddy listener that uses the existing source.

Envoy observation selects current `certificates[].cert_chain[]` entries by the exact URI SAN and ignores `ca_cert` entries.
Identical copies across loaded TLS contexts form one observation. Different current leaves for the same identity fail as ambiguous.
The JSON interface exposes no DER fingerprint. The exporter hashes the serial, sorted SANs, and validity times as an internal change token.
It ignores CA metadata, path names, and dynamic day counts for that token.
Envoy JSON supplies loaded metadata rather than a cryptographic chain check. No key or raw certificate is available through this interface.

Before probes, the collector reads all configured unit states in one command:

```text
systemctl show --no-pager --property=Id,ActiveState -- UNIT...
```

Only `ActiveState=active` permits a probe. `inactive` means dormant and produces no certificate sample.
Failed, activating, reloading, deactivating, missing, and malformed states fail observation. They never count as dormant.
This command reads state only and does not activate services or sockets.
A dormant target reports `observation_success=0` and `dormant=1`. Dormancy does not add an observation error or prevent aggregate collector success.
The `workloads` collector succeeds only when every target is either successfully observed or dormant.
A missing state or failed batch command fails all targets and clears their dormant indicators.

At most 16 holder observations run at once. The batch state read and all probes share the existing 20-second cycle budget.
The observer fetch runs in parallel with the batch state read. Envoy observations need no observer certificate.
If the observer API fails, TLS observations fail and clear their certificate samples. Envoy can still report its local loaded metadata.
The HTTP metrics listener remains available while either operation waits or fails.

Holder rotation timestamps record changes in the DER leaf fingerprint, or Envoy's public metadata digest.
The first observation, unchanged polls, and CA-only updates do not create a rotation timestamp.
A failure or dormant state preserves the last successful observation time and the internal change token, but removes the old certificate samples.
A fresh successful observation restores samples. Failure, known expiry, or 65 seconds without a current result clears observation success.
Dormant indicators also clear after 65 seconds. Holder rotation history resets after process restart and can miss intermediate rotations.
Fingerprints and serials never enter holder metric labels. Each holder metric uses `node,unit,identity,source`.

The bootstrap collector loads only `bundle_path` and makes a TLS 1.3 handshake.
It uses go-spiffe `tlsconfig` to check the chain, certificate times, and exact URI `spiffe://<trust_domain>/spire/server`.
DNS locates the endpoint. SPIFFE URI authorization supplies its identity check.
The probe sends no client certificate, enrollment request, or application request.
It uses no system roots, Workload API bundle, or fallback trust source.
The trust indicator expires with an actual verified chain, including its root.
A later expiry on an unrelated root cannot prove server trust.

The bundle inventory counts distinct CA certificates and those within their validity periods.
These counts describe the pinned file. Use native SPIRE telemetry for active authority statistics.
The exporter does not inspect, prepare, or activate SPIRE authorities.

The admin collectors execute only these commands, with fixed argument structure:

```text
spire-server agent list -socketPath SOCKET -output json
spire-server entry show -spiffeID spiffe://DOMAIN/agent/HOST -socketPath SOCKET -output json
```

Agent JSON must include `id={trust_domain,path}`, `attestation_type`, `banned`, `can_reattest`, and `x509svid_expires_at`.
The expiry is a decimal Unix timestamp encoded as a JSON string.
Each configured node must have exactly one current agent at `/spire/agent/http_fqdn/HOST`, type `http_fqdn`, `banned=false`, and `can_reattest=true`.
Missing booleans fail the check. Expired metadata fails the check but retains its public expiry for alerts until the collection becomes stale.
Agent certificate times come from admin metadata. They do not prove the trust of a live certificate chain.

Alias JSON must contain exactly one entry with the stable `spiffe_id`, expected `parent_id`, and one selector.
The selector must be `{type:"spiffe_id",value:"spiffe://DOMAIN/spire/agent/http_fqdn/HOST"}`.
Both IDs use `{trust_domain,path}` objects. A finite `expires_at` string must be current.
Only configured node names and stable aliases enter metric labels. Other agent IDs, including join-token IDs, never enter labels or logs.

| Metric | Labels | Meaning |
| --- | --- | --- |
| `realm_identity_collector_success` | `node,collector` | Current success, 0 or 1. |
| `realm_identity_collector_successes_total` | `node,collector` | Successful collections since process start. |
| `realm_identity_collector_errors_total` | `node,collector` | Failed collections since process start. |
| `realm_identity_collector_last_success_timestamp_seconds` | `node,collector` | Last successful completion, or 0 before success. |
| `realm_identity_collector_last_collection_timestamp_seconds` | `node,collector` | Last completion, or 0 before collection. |
| `realm_bootstrap_bundle_server_trust_valid` | `node` | Current successful pinned TLS check, 0 or 1. |
| `realm_bootstrap_bundle_certificates` | `node` | Distinct public CA certificates in the bundle. |
| `realm_bootstrap_bundle_active_valid_certificates` | `node` | Bundle CA certificates within their validity periods. |
| `realm_bootstrap_bundle_certificate_not_after_seconds` | `node,certificate` | Public bundle certificate expiry. |
| `realm_bootstrap_bundle_certificate_not_before_seconds` | `node,certificate` | Public bundle certificate start time. |
| `realm_identity_certificate_not_after_seconds` | `node,kind,identity` | Own canary expiry or configured agent expiry. |
| `realm_identity_certificate_not_before_seconds` | `node,kind,identity` | Own canary start time only. |
| `realm_identity_last_rotation_timestamp_seconds` | `node,kind,identity` | Own canary change observed by this process. |
| `realm_spire_agent_metadata_valid` | `node` | Expected agent metadata passes all checks. |
| `realm_spire_alias_matches_expected` | `node` | Stable alias matches its expected parent and selector. |
| `realm_workload_svid_observation_success` | `node,unit,identity,source` | Current successful holder observation, 0 or 1. |
| `realm_workload_svid_dormant` | `node,unit,identity,source` | Current unit state is inactive, 0 or 1. |
| `realm_workload_svid_last_attempt_timestamp_seconds` | `node,unit,identity,source` | Last completed attempt or dormant state read, or 0. |
| `realm_workload_svid_last_observed_timestamp_seconds` | `node,unit,identity,source` | Last successful certificate observation, or 0. |
| `realm_workload_svid_observation_successes_total` | `node,unit,identity,source` | Successful observations since process start. |
| `realm_workload_svid_observation_errors_total` | `node,unit,identity,source` | Failed attempts since process start. Dormancy adds no errors. |
| `realm_workload_svid_not_before_seconds` | `node,unit,identity,source` | Current observed leaf start time. |
| `realm_workload_svid_not_after_seconds` | `node,unit,identity,source` | Current observed leaf expiry. |
| `realm_workload_svid_last_rotation_timestamp_seconds` | `node,unit,identity,source` | Observed leaf change time. Absent before the first change. |

All time values use Unix seconds. Metrics with `_total` are counters. All other metrics are gauges.
`collector` is one of `bundle`, `bootstrap`, `canary`, `agents`, `aliases`, or `workloads`.
`agents` and `aliases` require admin collection. `workloads` requires a nonempty target list.
Collector `node` labels identify this daemon. Agent and alias `node` labels identify the configured target node.
`kind` is `canary` or `agent`. Canary `identity` is its observer ID. Agent `identity` is its stable `/agent/HOST` alias.
`certificate` is the SHA-256 fingerprint of public DER bytes. Certificate subjects, serials, keys, and arbitrary selectors are absent.

Collection starts at once and repeats about every 30 seconds. Each cycle has a 20-second deadline. Each remote operation has a 5-second deadline.
Alias commands share the cycle deadline. A large or slow cohort can fail the cycle.
Results become stale after 65 seconds. Known certificate or alias expiry clears success sooner.
The alias collector uses the earliest finite expiry in its cohort as a conservative deadline for its result.
A new failed result replaces the previous result. Failed reads remove old certificate samples. Staleness also removes certificate samples.
Partial admin results retain only metadata from the current response.
Current failures keep explicit agent and alias indicators at zero. Failures increment the relevant error counter and preserve the last successful timestamp.
Scrapes use a snapshot, so a slow HTTP client cannot hold the collector state lock.

The configuration limit is 256 KiB. The bundle limit is 1 MiB and 64 distinct CA certificates.
Each command has an 8 MiB stdout limit. Its stderr is discarded and its environment contains only fixed locale settings.
Logs contain bounded stage and reason values. The daemon does not read environment settings, agent data files, key files, proofs, or tokens.
The Workload API supplies the canary key in memory as part of its standard response. The exporter returns only public certificate metadata from that response.
Test keys use fresh random values in memory. No private key fixture enters the repository.

Run the package checks from this directory:

```console
go test ./...
go test -race ./...
go vet ./...
```

`default.nix` follows the repository `buildGoModule` pattern and runs the Go tests.
The dependency is go-spiffe/v2 v2.9.0. The existing `realm-agent/go.mod` has no go-spiffe version to reuse.

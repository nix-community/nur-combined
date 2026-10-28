# HTTP FQDN node attestation

Realm uses the standard SPIRE `http_fqdn` NodeAttestor on Agents and the Server.
Realm configures no join-token plugin and provides no token generator, installer,
or fallback mode. Stock SPIRE administrative features are not patched out.
SPIRE handles certificate signing and renewal. The plugin only approves node
attestation.

## Trust boundary

The cluster uses its existing WireGuard-backed mesh for bootstrap HTTP. Its
registry maps each exact node FQDN to a fixed mesh IP. The Server dials that IP
directly and supplies the registered FQDN as the HTTP Host header. It does not
query DNS, consult hosts files, accept a callback URL, or use an environment
proxy for this verification request.

The HTTP path still needs an explicit trust decision. `trustHttpTransport = true`
records that decision. It adds no encryption, peer authentication, or protection
against a compromised mesh router. A signature under a key supplied during an
untrusted HTTP exchange cannot independently authenticate the endpoint. The
nonce prevents replay but does not fix an untrusted transport.

Mesh participants and routing administrators therefore join the bootstrap trust
boundary when this deployment uses mesh HTTP. Workload connections still require
SPIFFE mTLS and receiver authorization. Mesh membership does not grant service
permissions.

Agents authenticate the Server's TLS connection with a pretrusted public bundle
and its expected SPIFFE ID. Never enable `insecure_bootstrap`. SSH remains a
management and initial public-bundle provisioning channel. It does not issue
node enrollment tokens.

## Endpoints and identities

| Purpose | Cluster value for Abhoth |
| --- | --- |
| Node FQDN | `abhoth.nyaw.xyz` |
| Registered destination | `fdcc::5` |
| HTTP proof | `http://abhoth.nyaw.xyz:18091/.well-known/spire-node-attestation/v1/<id>` |
| Actual connection | TCP `[fdcc::5]:18091`, with Host `abhoth.nyaw.xyz:18091` |
| Server connection | `eihort.nyaw.xyz:8081`, mapped to `fdcc::3` |
| Local publish API | `/run/realm-node-attest/control.sock` |
| Actual Agent ID | `spiffe://nyaw.xyz/spire/agent/http_fqdn/abhoth` |
| Stable parent alias | `spiffe://nyaw.xyz/agent/abhoth` |

The HTTP proof endpoint is a custom challenge, not an ACME HTTP-01 endpoint.
It runs independently of Caddy and Realm proxies. Cluster responders bind only
their assigned mesh IPv6 address. They do not open the proof port on public
interfaces. NAT nodes use their mesh address like other nodes.

`mod/realm.nix` derives the Server allowlist from enabled Realm hosts and the
registry's `unique_addr_nomask` values. It also provides the Server's hosts entry.
FQDN suffixes do not grant admission. The reusable module accepts explicit
literal unicast pins, including ULA and LAN addresses. It rejects loopback,
link-local, unspecified, multicast, and mapped addresses.

## Protocol

1. The Agent authenticates the Server over TLS. SPIRE's normal `AttestAgent` RPC
   carries its CSR. The agent plugin sends version 1, its FQDN, and an ephemeral
   Ed25519 public JWK. The bootstrap private key stays in plugin memory.
2. The server plugin checks the exact FQDN allowlist and reserves a bounded
   pending session. It generates independent 32-byte challenge and nonce values.
   The challenge binds its FQDN, trust domain, Server ID, public-key thumbprint,
   and an expiry 120 seconds after issuance.
3. The agent plugin checks these values and signs the exact challenge bytes as a
   compact JWS. It publishes the proof through the root-only Unix API, then sends
   `ready` over the original attestation stream.
4. The server plugin fetches the proof from a pinned literal destination. It
   checks the public key, EdDSA signature, original challenge bytes, expiry, and
   session state. A proof cannot approve another session.
5. The plugin returns the approved Agent ID and selectors. SPIRE checks node
   state and bans, signs that stream's CSR, and returns the Agent SVID through
   the original TLS connection.

A proof response contains no token, certificate, or private key:

```json
{
  "bootstrap_jwk": {
    "kty": "OKP",
    "crv": "Ed25519",
    "x": "<base64url-public-key>"
  },
  "proof": "<compact-JWS>"
}
```

Only EdDSA and the protected type `spire-http-node-attestation+jws` are accepted.
The JWS payload must equal the issued challenge bytes. No key is fetched from a
header URL. This bootstrap signature is classical, not post-quantum.

The responder receives only signed public proofs. It has no bootstrap private
key, Agent key, Workload API socket, or application credential. Proofs stay in
memory and disappear on deletion, expiry, or restart. The plugin cleans up its
proof when SPIRE closes the stream.

## Bounds and lifecycle

The server plugin allows 32 pending sessions. Unverified claims do not reserve
an exclusive node slot or consume its issuance quota. Only valid proofs count
toward the limit of six successful attestation approvals per node per minute.

The challenge deadline is 120 seconds. Fetches have a five-second budget. Proof
bodies and HTTP headers are limited to 8 KiB. Redirects, compressed responses,
and environment proxies are disabled. Only the configured literal addresses are
dialed, so DNS or hosts changes cannot redirect a fetch.

The responder stores at most four proofs and permits 32 connections per
listener. Public HTTP provides GET only. Publication and deletion use a separate
Unix listener, protected by file permissions and kernel UID 0 peer checks.
Systemd passes the sockets to a service without root privileges. The service has
CPU, memory, and task limits and starts without SPIRE credentials.

The module defaults to HTTP attestation when Realm is enabled. The Server plugin
follows `realm.spire.server.enable`. The transport trust decision remains
explicit in the reusable module. Cluster policy supplies it for the trusted mesh.

A valid cached Agent identity survives normal restarts. With
`rebootstrap_mode = "always"`, expired identities can reattest while the node
still trusts the Server and controls its pinned endpoint. A banned Agent ID
cannot bypass its ban with a new HTTP proof.

These limits apply per plugin process. Multiple Server replicas need a separate
review of pending admission and concurrent attestation. No distributed lock is
implemented.

## Public bundle provisioning

Cluster migration retains the trusted public bundle at
`/var/lib/realm-spire/trust-bundle.pem`. That file is trust material, not token
compatibility. Refresh it through the trusted management channel before forcing
a new attestation. The Server's signing keys, datastore, and trust domain stay
unchanged during this migration.

The reusable module defaults to `/etc/realm-spire/trust-bundle.pem`. A missing
bundle skips Agent startup. A runtime check requires a certificate and rejects
private-key markers. An operator can instead set `trustBundle.path` or
`trustBundle.text` to distribute public certificates through Nix. Pinned sources
take precedence over the runtime path.

Do not put private keys in Git, expressions, generated store files, or logs.
Public bundles can be tracked. A bootstrap bundle must remain trusted and
current. Automatic leaf renewal does not fix an obsolete bootstrap root after a
long offline period. Root rotation needs trust continuity or a management update.

## Migration and validation

Use [the migration runbook](realm-deployment.md). Migrate Eihort's Server first,
then validate each Agent and its actual ID. Skip Uubboo and Kaambl for this run.
Migrate Hastur last. Do not use a valid old cache as evidence of HTTP attestation.

Package tests cover pinned destinations, session replay, key substitution,
redirect denial, expiry, peer credentials, cancellation, and resource bounds.
SDK tests cover configuration and stream lifetimes. The VM tests use real SPIRE,
external plugins, isolated IPv6 pins, systemd sockets, workload issuance through
stable aliases, and node bans. Business fixtures also use the sole HTTP method.
Deployment results remain separate from fixture results.

# Security policy and trust model

This public repository declares a distributed NixOS cluster and its Realm
workload networking. Protect host integrity, application data, runtime secrets,
workload identities, and the authorization boundaries between services.

This document records the intended trust model and review requirements. It is
not a claim that every host runs the latest revision, that every service uses
Realm isolation, or that the repository has passed a comprehensive security
audit. Check the evaluated host configuration and running system. Deployment
evidence, including its scope and limitations, lives in
[the rollout record](docs/realm-agent-rollout.md).

## Reporting a vulnerability

Report a suspected boundary violation privately to the repository owner. Use
the repository's private vulnerability reporting feature if enabled; otherwise
arrange a private channel with the owner before sending sensitive details. This
repository does not currently document a dedicated security inbox or response
SLA. Do not put credentials, private keys, personal data, or a working exploit
against a deployed service in a public issue or pull request.

Include the relevant commit, affected component and configuration, attacker
prerequisites, the intended boundary, actual impact, and a minimal reproduction
using synthetic data. Distinguish source evidence from behavior that still
needs validation. Repository visibility is not authorization to probe the
cluster. Availability testing, host changes, and tests against production
identities or data require the operator's explicit authorization.

## Trusted components and attacker capabilities

Assume an attacker can send arbitrary network requests, influence DNS and
remote application content, or gain code execution inside one unprivileged
application. Treat that application's sockets, packet contents, connection
patterns, and writable files as hostile input to adapters and privileged code.

The trusted base includes:

- Host root, the kernel, systemd, and the mechanisms enforcing credentials,
  cgroups, namespaces, mount permissions, and BPF attachment.
- The privileged realm-agent controller and its root bootstrap, SPIRE Server
  and Agents, enrollment administrators, and identity registration policy.
- The proxies and gateways that hold workload credentials and enforce TLS or
  receiver authorization, within their assigned authority.
- Deployment administrators and keys, the deployed Nix configuration, flake
  inputs, package sources, and accepted build outputs and substituters.

Host root can bypass local enforcement, access decrypted secrets, and exercise
the identities assigned to that node. A compromised SPIRE Server or enrollment
authority can undermine identity issuance more broadly. Node registration scope
and receiver permissions therefore matter even when node administrators are
trusted. A shared kernel is not a virtual-machine isolation boundary.

An application compromise must not by itself grant host administration,
another workload's credentials, or access outside the application's declared
capabilities. It does grant access to that application's own data, secrets,
mounted sockets, and allowed services. Public egress can carry stolen data.
Application and database permissions must limit what an admitted caller can do.

## Trust boundaries

### Network location and discovery do not establish identity

Mesh membership, VXLAN or Yggdrasil reachability, source addresses, DNS names,
and catalog publication do not authorize a service connection. Realm's trust
domain is `nyaw.xyz`; its discovery domain is `mesh.nyaw.xyz`. Neither resolving
a name nor appearing in discovery proves that an endpoint is ready or trusted.

Inter-service clients must verify the expected server SPIFFE identity. Receivers
must authenticate the caller and enforce their explicit final identity policy.
Declaring an egress does not grant receiver access. Unknown or ambiguous catalog
references must fail configuration validation; manual targets require a separate
review of their actual server identity and receiver policy.

Node enrollment uses the HTTP FQDN attestor over an explicitly trusted path.
The Server dials registry-pinned literal node addresses. It does not use DNS or
hosts resolution for proof fetches. Cluster deployment uses the existing
WireGuard-backed mesh and trusts its bootstrap path, routing administrators, and
participating host roots. That trust decision is separate from workload grants.

A nonce and signature under a newly supplied key do not authenticate an untrusted
HTTP path. An attacker who can replace that path can authorize another key. The
root-only local publish socket is an administrative capability. Public GET
responses contain only short-lived proofs. Agents authenticate the Server with
a pretrusted public bundle. SSH supplies management access and initial bundle
provisioning, not node enrollment tokens. No token fallback is configured.
See [the HTTP attestation guide](docs/realm-http-attestation.md).

### Unix credentials and identity registrations

Proxy-mode applications use dedicated proxies rather than receiving SVID keys
or the SPIRE Workload API socket. Registrations bind the actual proxy/helper
systemd unit and Unix user. Native TLS workloads are an explicit exception:
their own unit and user are registered, and they must implement the declared
authentication and authorization themselves.

Separate SPIFFE IDs are required when separate remote permissions are needed.
Instances sharing an ID share its authority. Separate Unix users and suitable
socket groups are required when local separation is needed. Native gate unit
checks distinguish requests from units sharing a UID; they do not turn that UID
into separate Linux security principals. Rootless transparent workloads require
an exclusive application UID.

Unix sockets are capabilities. A read-only bind mount still permits connecting
to a socket; mounting its parent directory exposes other accessible entries
there and makes replacement sockets visible. Review ownership, mode, group
membership, peer-credential checks, and every exposed directory. Local database
peer authentication must map only the intended Unix principal to its SQL role;
database grants remain a separate authorization layer.

### Applications, host networking, and explicit exceptions

Eligible isolated workloads have private network namespaces without external
links or a default route. Their host runtime socket view is restricted to
declared paths. Rootless containers use `network=none`, the configured user
mapping, and dropped capabilities. Loopback adapters and Unix egress sockets
provide the declared connectivity.

Host-network gateways, external runtimes, explicitly exempted services, and
unmigrated applications have different exposure. Review each exception and its
direct listeners, mounts, credentials, and administrative interfaces. Automatic
realm-agent enrollment applies to eligible private-network workloads; a Realm
registration alone does not imply capture or isolation.

### Transparent realm-agent control and data paths

The agent adapts TCP and ordinary DNS to existing egress capabilities. It does
not issue SPIFFE identities, expand receiver grants, or replace application TLS.
Ghostunnel and native gateways retain remote authentication and authorization.

The following invariants must survive implementation changes:

- Each control socket is root-owned and limited to its configured application
  group. Gate requests supply no trusted PID, cgroup, namespace, or identity.
  Derive credentials from the socket, pin the original peer with
  `SO_PEERPIDFD`, and open its process state without a PID-reuse substitution.
  Native callers must match the configured host system unit as well as UID.
- Recover only an independently verified workload cgroup and namespace pair.
  Saved state and recycled paths are insufficient attribution. Never attach
  workload BPF programs to the host cgroup root, a shared slice, the Internet
  gateway, or a host TUN proxy.
- Reject the host network namespace and externally connected namespaces.
  The workload-local dummy interface supplies address-family availability,
  not an external route. Applications receive no network-administration or
  BPF privileges.
- Keep the packet-facing worker unprivileged, separate from the application's
  cgroup, and limited to its own declared egress capabilities. Its filesystem
  view exposes the read-only Nix store, CA bundle, and declared socket
  directories. It must not expose the SPIRE API, host runtime sockets,
  application state, or writable cgroup/namespace control descriptors.
  Sealed configuration and a read-only destination-map descriptor must retain
  their restrictions after bootstrap drops credentials and capabilities.
- Attribute accepted TCP connections using the correct network namespace,
  connection tuple, and kernel-maintained original destination. Missing,
  stale, or evicted metadata must close the connection. Route selection must
  preserve explicit prefix/port rules and normalize mapped address forms.
- Bound parsing, DNS queues, upstream queries, TCP sessions, maps, and worker
  resources. A workload's recovery error, listener conflict, or worker OOM
  must not abort unrelated worker recovery. Controller readiness does not
  replace each application's worker-readiness gate.
- Unsupported kernel features, sandbox failures, missing routes, and lost
  workers must not silently enable direct networking or an unsandboxed worker.
  Keep startup attribution and recovery state valid across gate-to-ExecStart
  gaps, application restarts, and rootless container replacement.

The root controller remains a privileged attack surface. Per-worker resource
budgets and recovery reduce interference; they do not guarantee host-wide
availability. Controller failure can interrupt every captured workload's
transparent traffic, and recovery can break existing connections.

### Internet and shared HTTPS gateways

The Internet gateway must authenticate admitted SPIFFE callers and enforce
destination restrictions independently of the local agent. Review DNS answers,
IP literals, and the selected upstream address, including IPv4-mapped IPv6 and
private, loopback, link-local, metadata, multicast, and other denied ranges.
Additional CONNECT ports need receiver-side permission for the intended
identities. The agent's `internetPorts` is an adapter restriction; existing
Unix and loopback proxy paths remain capabilities subject to gateway policy.

Public egress policy is based on addresses and ports, not a domain allowlist.
DNS aliases, `/etc/hosts`, `resolveHosts`, and proxy environment variables select
routes or application behavior. They do not authorize domains, paths, or users.
Admission to a shared HTTPS gateway grants its listener-level access; Caddy
and the backend must enforce any finer restrictions. Split gateways or policies
when listener-level authority is too broad.

Ordinary UDP/TCP DNS is captured; application DoH or DoT remains application
traffic. Permitted HTTPS can tunnel other protocols. Other external UDP,
including QUIC, is unsupported and denied by the transparent path. Do not claim
that every resolver implementation or encrypted DNS protocol is overridden.

Host sing-box/TUN routing remains downstream of the authenticated gateway.
Fake-IP mappings belong to the proxy instance that issued them; do not turn
them into workload service aliases or forward them to a different gateway.

### Public ingress and application authorization

Public HTTPS authenticates the server to a public client. A Caddy Realm identity
authenticates the forwarding gateway to a private backend; it does not identify
the end user. Preserve application authentication, database roles, tenant and
resource checks, protected path rules, and explicit public-share exceptions.
Trust forwarded client headers only from the intended protected ingress.
Keep metrics, debug endpoints, and management APIs outside business listeners
unless an explicit policy protects them.

## Secret handling and supply chain

Never commit plaintext secrets, private keys, enrollment tokens, decrypted
configuration, or sensitive diagnostic output. Public keys, public trust
bundles, and encrypted Vaultix material may be tracked. Encryption recipients
and host assignments are security policy and require review.

Do not interpolate secret values into Nix expressions, generated derivations,
command lines, build logs, or store paths. Treat the Nix store and build outputs
as public. Supply runtime secrets through narrowly permissioned credentials or
explicit read-only mounts. An ignored plaintext working directory is not a
security boundary: exclude it from source copying, flake inputs, artifacts,
and backups that lack suitable protection.

Review flake/input updates, overlays, package patches, binary hashes,
substituter trust, and container images as executable supply-chain changes.
An immutable Nix store does not prove that its contents are trustworthy; a
mutable image tag does not identify the bytes actually deployed. Private-key
hooks are useful checks, not proof that a diff contains no secrets.

## Security review and validation checklist

Review in this order, using checks appropriate to the change:

1. **Authority:** Name the lower-trust principal, accepted input, protected
   resource, intended control, and concrete consequence. Compare effective
   receiver grants, identities, groups, socket access, and exceptions before
   and after the change. Avoid interpreting intended same-principal access as
   a new boundary violation.
2. **Privileged transitions:** Check gate attribution, PID/cgroup/namespace
   lifetime races, descriptor inheritance, path traversal and symlinks,
   directory ownership, credential dropping, capabilities, and mount scope.
   Prefer kernel-derived state over caller-provided labels.
3. **Policy bypass:** Exercise both authorized and unauthorized callers,
   incorrect server identities, undeclared egress, private/mapped destinations,
   alternate socket paths, and direct listeners. Check the receiver as well as
   local adapters; include application and database authorization where relevant.
4. **Failure containment:** Check malformed and oversized input, bounded
   concurrency, queue/map exhaustion, worker crashes, occupied ports, bad
   recovery state, and startup/restart gaps. Resource exhaustion tests belong
   in disposable synthetic cgroups, never in production application cgroups.
5. **Configuration and packages:** Evaluate affected hosts and relevant
   `tests/realm-*.nix` fixtures; build changed packages with their checks.
   Agent changes also need kernel attachment and synthetic integration checks
   on the affected architecture/kernel. Use
   [the agent fixtures](pkgs/realm-agent/README.md#validation) and
   [Realm VM tests](tests/realm-vm.nix) as applicable. A successful build does
   not establish runtime enforcement.
6. **Deployment:** Keep a reachable administrative path and previous generation.
   Review activation changes, deploy incrementally, and verify actual process
   executables, configuration, credentials, namespaces, BPF attachments,
   resource cgroups, and remaining runtime overrides. Unit contents and
   `active` status alone are insufficient. Test from the application's actual
   UID, cgroup, network namespace, and mount/hosts view; check real business
   operations and expected denials. Record host/revision scope and failures.

Use synthetic principals and data for reproductions. Do not dump ambient
environments, decrypted configurations, or credential-bearing request logs.
Run untrusted code in a bounded disposable sandbox. Keep live testing within
explicitly authorized hosts and operations.

## Revocation, recovery, and residual risk

Short-lived SVIDs and connection lifetime limits reduce exposure but do not
provide instantaneous revocation. Removing an identity registration does not
immediately terminate established TLS sessions. For urgent containment, revoke
the relevant grants and stop or restart affected connections/processes as
needed; replace exposed application secrets and assess the issuing node or
control plane. Preserve evidence without publishing sensitive data.

System generation rollback does not undo database migrations, restore leaked
secrets, or erase persistent application state. Secure Boot, disk encryption,
and ephemeral roots apply only on configured hosts and depend on their actual
enrollment and storage state. Backups and persistent paths need their own
access controls. No control here guarantees availability or protects a host
after compromise of its trusted root/kernel.

## Implementation references

| Area | Source and documentation |
| --- | --- |
| Cluster declarations and compilation | [Registry](registry.toml), [host compiler](mod/os.nix), [Realm reference](docs/realm.md) |
| Isolation and local capabilities | [Workload isolation](lib/realm/base.nix), [container integration](nixosModules/realm-container.nix) |
| Identity and receiver grants | [SPIRE](nixosModules/realm-spire.nix), [egress](lib/realm/egress.nix), [ingress](lib/realm/ingress.nix), [native TLS](lib/realm/native.nix) |
| Transparent capture and worker containment | [Agent source](pkgs/realm-agent/), [agent integration](nixosModules/realm-agent.nix), [architecture](layout/transparent-egress.svg) |
| Gateway policy | [Internet restrictions](lib/realm/envoy-internet.nix), [site Internet grants](mod/realm-internet.nix), [Caddy identity policy](mod/realm-caddy-policy.nix) |
| Secrets and administrative access | [Vaultix](mod/vaultix.nix), [host secret assignments](mod/age.nix), [SSH policy](mod/openssh.nix) |

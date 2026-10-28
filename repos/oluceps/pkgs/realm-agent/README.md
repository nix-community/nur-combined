# Realm host agent

`realm-agent` is a separate static Go executable with embedded C BPF programs.
It transparently adapts application sockets to existing Realm egress sockets.
Ghostunnel and the receiving gateway retain all SPIFFE authentication, TLS,
certificate rotation and authorization responsibilities.

The NixOS integration is in `nixosModules/realm-agent.nix`. Enabled workloads
with private networking join automatically: native systemd services and rootless
containers declared through `workload.container`. Host-network gateways and
`runtime = "external"` entries stay outside capture. There is one host daemon,
with a separate unprivileged worker, resource cgroup, mount namespace and BPF
attachment per workload.

Set `realm.agent.enable = false` to disable the host daemon and all gates, or
`realm.workloads.<name>.transparent.enable = false` to exclude one workload.
`mod/realm-agent.nix` excludes the laptop kaambl from automatic enrollment. No per-host service list is needed, including for newly added workloads.

A unique declared egress whose service is `internet-proxy` becomes the default
`internetRoute`, regardless of whether it came from `http.internet` or a manual
egress declaration. Several matching egresses require an explicit choice.
Workloads with no such egress keep external DNS and public TCP disabled. This
does not register new SPIFFE identities or grant new gateway permissions.

## Declaration

```nix
realm.workloads.example.transparent = {
  # Optional: inferred automatically from a unique internet-proxy egress.
  internetRoute = "internet"; # Must already exist in this workload's egress.
  internetPorts = [ 443 ];
  dnsHosts."s3.example.org" = [ "127.0.0.1" ];
};
```

The alias can select an existing loopback adapter. Alternatively, an internal
service can have a separate virtual address and an explicit route:

```nix
realm.workloads.example.transparent = {
  enable = true;
  dnsHosts."service.example.org" = [ "203.0.113.7" ];
  routes = [ { prefix = "203.0.113.7/32"; port = 443; egress = "service"; } ];
};
```

`203.0.113.7` is an illustrative workload-local address, not a globally
allocated service address. DNS supplies location, never identity. Route
selection opens a declared Unix socket; its existing ghostunnel validates
the receiving SPIFFE ID. A shared HTTPS gateway still has its existing
gateway-level permissions, rather than acquiring hostname authorization from
the alias. Split gateway policy if distinct hostname authorization is needed.

Systemd applications use a generated `ExecStartPre` readiness gate. Containers
must run `realm-helper launch` with `network=none`, the configured rootless user
and `REALM_AGENT_SOCKET`; the module adds the socket directory mount and this
environment variable. The helper performs the gate before launching the app.
Workload units use `Wants` and `After` for the agent; the gate enforces readiness
without propagating an agent restart to the application. Loss of the agent
leaves the isolated namespace without external connectivity until recovery.
Native HTTP proxy environment injection is omitted for transparent workloads;
existing application-specific proxy configuration can continue to work through
the unchanged loopback adapters.

Public HTTP on port 80 needs `internetPorts = [ 80 443 ]` **and** receiver-side
permission for CONNECT to port 80. The existing Internet gateway admits CONNECT
to 443 by default. The agent cannot grant itself new receiver permissions.

## Startup and trust boundary

1. The root host agent owns a distinct, group-accessible Unix control socket per
   workload. The client supplies no PID, cgroup, namespace or identity.
2. `SO_PEERCRED` supplies the caller UID and host PID. The agent requires the
   configured application UID and uses `SO_PEERPIDFD` to pin the socket's original
   peer. A liveness check after opening its proc directory rejects exit/PID reuse
   before that open; subsequent `openat` calls stay bound to the original proc. It obtains
   its real cgroup and network namespace with `openat`. Native callers must also
   belong to the configured system unit beneath host-managed slices. A sibling
   unit with the same UID, a user-manager unit, or a name inside another
   delegated service cannot select that workload. Capture covers the complete
   unit, including a gate in its `.control` subgroup.
3. The agent rejects the host network namespace, external-capable interfaces,
   and default routes. It creates an isolated `realm0` dummy with
   `192.0.2.254/32` and `2001:db8::ffff/128`. These addresses satisfy
   AI_ADDRCONFIG clients but provide no external link or default route.
   Kernel-created `ip6tnl0`, `gre0`, `gretap0` and `erspan0` fallbacks may remain
   only when marked namespace-immutable and DOWN, without addresses, endpoints
   or routes. Neither the app nor worker can
   configure it. Operational tunnel interfaces are rejected.
4. BPF hooks attach to that cgroup. A trusted root bootstrap joins the network
   namespace with `nsenter` before the Go runtime starts, enters the workload's
   independent worker resource cgroup, and creates a private mount namespace.
   It pivots into a read-only root containing the Nix store, the configured CA
   bundle and only declared egress socket directories. Socket directories are
   bound read-only so socket replacement remains visible. Broad runtime roots
   and symlinked source directories are rejected. `/proc`, `/sys`, host runtime
   sockets, application state, and writable cgroup descriptors are absent.
   The bootstrap clears supplementary groups and capabilities, changes to the
   distinct `rnet-<workload>` UID and workload socket-access group, closes the
   namespace descriptor, and execs the worker. The worker is outside the
   application's cgroup and does not receive the SPIRE socket.
5. The worker binds both address families and signals readiness. Only then does
   the application gate open. No `CAP_NET_ADMIN` or BPF privilege reaches the app.

For rootless Podman, the actual container cgroup is discovered from the helper
process. No guessed `libpod-*.scope` name, polling race, or broad user-slice
attachment is required. One active cgroup/namespace pair is allowed per declared
workload. Rootless containers require an exclusive application UID; the module
and daemon reject sharing that UID with another declared workload. Native
workloads can share a UID only with distinct attested system units. This binds
gate requests to units; it does not make a shared Unix UID into separate Linux
security principals or change permissions on existing Realm sockets.

Root necessarily controls the host enforcement boundary. A workload's Unix
credentials and cgroup are local attribution, not a remote cryptographic
identity. Remote identity continues to come from its dedicated SPIFFE proxy.

## Data path

The embedded object attaches these cgroup programs:

| Hook | Purpose |
| --- | --- |
| `connect4`, `connect6` | Record the original TCP destination and redirect the connection to the local TCP adapter. |
| `sendmsg4`, `sendmsg6` | Redirect UDP DNS to one of the local resolver slots; other external UDP is denied. |
| `recvmsg4`, `recvmsg6` | Restore the resolver source address on UDP replies. |
| `getpeername4`, `getpeername6` | Report the original peer address to the application. |
| `sockops` | Publish the established TCP tuple and original destination; delete it on close. |

Userspace performs DNS parsing, CONNECT, TLS and byte forwarding. The programs do not parse DNS messages or application payloads.

TCP `connect4` / `connect6` store the original address in socket storage and
rewrite the destination to the private namespace's TCP adapter. The active
established sockops callback publishes the connection tuple and original
destination in a 16,384-entry LRU map that is read-only to userspace. The
accepted worker socket uses its namespace cookie and peer tuple to find this
record. An accepted socket has a different socket cookie from the client;
`SO_ORIGINAL_DST` is not assumed. A normal TCP close deletes the entry. Missing
records, including LRU eviction, close the connection.

Internal targets use the most specific declared prefix/port route. Public
targets require an allowed port and the configured Internet egress. The worker
synthesizes CONNECT before forwarding bytes. Private/reserved destinations are
rejected unless explicitly routed. IPv4-mapped IPv6 addresses are normalized
before that check. HTTPS payloads and their certificate verification remain
end to end. Existing loopback adapters remain usable.

DNS uses connect and UDP sendmsg/recvmsg hooks, including TCP DNS. Each UDP
socket has eight stable original-resolver slots. The worker binds those eight
ports on both `127.0.0.1` and `::1`, giving 16 UDP listeners; TCP DNS uses the
same TCP adapter as ordinary TCP when the original port is 53. Reply-source and
peer-name hooks restore the resolver address seen by the application. This
supports multiple simultaneous resolvers without treating the last send as the
source of every reply. When all eight slots are occupied by other peers, the
query is dropped rather than reassigning an outstanding slot.

Declared DNS aliases are authoritative. Other queries use DNS-over-HTTPS through
the same authenticated Internet egress, without needing a bootstrap DNS socket
or a direct route. Without Internet egress, unknown names receive REFUSED. DNS
message sizes, concurrent upstream queries and TCP sessions are bounded.

Host TUN proxies such as sing-box remain downstream of Realm's authenticated
gateway. Their fake-IP DNS answers do not populate the application's resolver:
external answers come from DoH, and workload aliases are answered locally.
The gateway may still use the host resolver to reach the DoH endpoint, and its
outbound sockets may traverse the host TUN. Preserve that routing; do not attach
the workload's BPF programs to the gateway, sing-box, or a shared host slice.
Fake-IP mappings belong to the proxy instance that issued them and must not be
copied into workload service aliases or sent to a gateway on another machine.
The rootless fixture checks eihort's custom fake-IP pools explicitly.

## Lifecycle and limits

The controller keeps cgroup and namespace descriptors for active workers.
It records only the cgroup path and cgroup/namespace inode pair in root-owned
0600 `state.json`, beside each control socket. After restart it searches that
cgroup for a process with the expected UID and matching namespace before
reattaching. Recycled PIDs/cgroup paths do not suffice. An empty cgroup releases
its worker and state. A crashed worker is recreated on the next reconciliation.

Each workload has its own reconciliation goroutine. Occupied listeners, bad
saved state or slow recovery affect that workload only; controller readiness
means all control sockets exist, while each application gate still requires its
own forwarding worker to be ready. Recovery is retried every two seconds,
including after an independently enforced worker OOM.

Workers inherit a read-only connection-map descriptor, sealed read-only config and a parent-liveness
pipe. EOF on the pipe stops the worker even if the controller is killed. The
systemd unit also uses `KillMode=control-group`. There is no fallback Internet
route when the controller, worker, BPF links or DNS upstream are unavailable.
Existing proxied connections can break during recovery and must be retried by
the application; this is not a connection-preserving hot upgrade.

Defaults are 256 concurrent TCP connections per workload, 64 concurrent DoH
queries per workload and 16,384 original-destination records per workload map.
UDP DNS has 64 fixed workers per workload and a 128-datagram queue shared by its
16 listeners; excess requests are dropped before parsing, and truncated
datagrams are rejected. Adapter ports are private to each namespace. Worker
accounts have no login shell, no new privileges and are not dumpable.

The controller requires a cgroup-v2 systemd unit with `Delegate=cpu memory pids`
and `DelegateSubgroup=supervisor`; it refuses arbitrary/non-delegated launch
cgroups. The supervisor has a 256 MiB/128-task budget. Each worker defaults to
128 MiB, zero swap, 64 tasks, and 100% of one CPU (`cpu.max`), with grouped OOM
inside that leaf. Set `transparent.workerMemoryMiB`, `workerTasks` or
`workerCPUQuota` to tune a workload. The parent unit limit is the sum of leaf
budgets plus headroom, and `OOMPolicy=continue` lets one worker's OOM recover
without killing the supervisor or siblings. The writable host cgroup mount is
limited to `system.slice/realm-agent.service`; changing that unit's slice also
requires adjusting the mount exception.

`SO_PEERPIDFD` requires Linux 6.5 or newer. The sandbox also requires `openat2`,
`mount_setattr` and mount namespace support; there is no unsandboxed fallback.

This version supports TCP and ordinary UDP/TCP DNS. Other external UDP is
rejected, including QUIC. DoH/DoT used by applications do not become ordinary
DNS queries; arbitrary permitted HTTPS cannot simultaneously guarantee that all
application DoH is identified or overridden. Application-level refusals to use
an IP address remain application behavior. Public destination authorization is
IP/port based, not a domain allowlist.

## Validation

Nix builds compile the BPF object with unwrapped Clang and execute Go unit tests.
The package has no runtime dependency on libbpf or a C library. BPF hooks use
the kernel's UAPI context fields. Kernel loading and attachment must be verified
on each supported kernel; this branch was validated on Linux 6.18.x (6.18.54 on
eihort). Re-check hook availability and behavior after a kernel upgrade.

Configuration tests:

```sh
nix-instantiate --eval --strict --json --expr \
  'import ./tests/realm-agent.nix { nixpkgs = <nixpkgs>; }'
```

Remote integration fixtures live under `tests/realm-agent-*`. Run them only on
an authorized test host. `realm-agent-integration.py` creates a transient
PrivateNetwork service and tests IPv4/IPv6 TCP, UDP/TCP DNS, simultaneous resolver
peers, bounded overflow, half-close, private-address denial, same-UID unit
impersonation refusal, worker recovery,
agent restart and lack of a direct route while stopped. `--internet` additionally
uses the existing Misskey Internet egress to fetch example.com without proxy
environment variables. It requires the existing `misskey` and `nobody` accounts.

`realm-agent-rootless.py` uses the existing local Misskey image twice with
`--pull=never`, `network=none`, keep-id and dropped capabilities. It verifies
the real CacheableLookup DNS behavior, its ADDRCONFIG path, the public S3 avatar
through the declared internal route, and public HTTPS with no proxy settings.
It mounts the public CA bundle but does not mount application secrets or data.
The production Misskey container is not restarted by these fixture runners.

`tests/realm-agent-hardening.py` uses two synthetic workloads and a separate
delegated controller. It verifies the minimal filesystem view and resource
limits, holds a worker port across controller restart to check sibling recovery,
and induces OOM only inside a synthetic 32 MiB worker cgroup. The controller and
sibling must survive and the affected worker must recover. Production agents
are not restarted by this fixture.

An empty, dedicated cgroup can also validate kernel support:

```sh
realm-agent check-kernel --cgroup /sys/fs/cgroup/a-dedicated-empty-test-cgroup
```

Never point this probe at a production cgroup or the cgroup root.

## Pilot rollback

For a runtime pilot, keep the previous container unit/start script and the new
Nix closures rooted. A runtime drop-in can replace only the container's start
script and add the agent dependency. Remove that drop-in, daemon-reload and
restart the container to restore the previous launch configuration; stop the
agent afterwards. Runtime overrides under `/run/systemd/system` do not survive a
reboot. A normal deployment of the branch's eihort configuration is required
for persistent activation. For declarative rollback, disable
`realm.workloads.misskey.transparent.enable` and deploy normally.

# SPIFFE workload networking

The `realm` flake module is imported by `vxlan-mesh`. SPIRE Server runs on
eihort; mesh nodes run an Agent. Each node runs a local CoreDNS discovery
listener. The trust domain is `nyaw.xyz`, independently of the discovery
DNS domain `mesh.nyaw.xyz`.

## Declaration model and compilation

Realm compiles local declarations into a fixed output record. No runtime controller resolves these declarations.

| File | Responsibility |
| --- | --- |
| `lib/realm/types.nix` | Workload and legacy option types |
| `nixosModules/realm-model.nix` | Backend normalization, identity references and authorization reports |
| `lib/realm/compile.nix` | Compose the local compiler stages |
| `lib/realm/{base,egress,ingress,socks,native}.nix` | Generate isolation, adapters and identity registrations |
| `lib/realm/outputs.nix` | Merge the fixed output fields |
| `nixosModules/realm-http.nix` | HTTP proxy settings and shared internal HTTPS gateway adapters |
| `nixosModules/realm-container.nix` | Shared container mounts and loopback routes |
| `nixosModules/realm-internet.nix` | Reusable Internet gateway service |
| `mod/realm-internet.nix` | Site caller policy and extra CONNECT permissions |

The compiler returns `services`, `sockets`, `userGroups`, `users`, `tmpfiles`, `registrations`, `publications` and `assertions`. Each field has its own merge. The compiler does not inspect the internal representation of `mkIf` or `mkMerge`.

Local identity exports depend only on enabled workload declarations. Cluster aggregation collects these exports and the published endpoints. Egress resolution uses the resulting catalog. Keep exports independent of egress resolution to avoid an evaluation cycle.

`mod/custom-modules.nix` exports module paths. This lets Nix deduplicate a reusable module imported by both the default module collection and a standalone service profile.

### Backend types and receiver policy

Declare `ingress.<name>.backend` with one of these kinds:

| Kind | Fields | Connection |
| --- | --- | --- |
| `unix` | `path`, optional `peerUser` | Unix socket |
| `private-tcp` | `port`, optional loopback `address` | Adapter inside the workload namespace |
| `host-tcp` | `port`, IPv4 loopback `address` | Explicit host networking exception |
| `native` | No backend address | Application terminates SPIFFE TLS |

Native consumers must enforce the declared identities themselves. The Caddy and Envoy generators use the final ingress policy. The native flag alone does not implement authorization.

Receiver grants support three forms:

- `allow.workloads`: references to declared workloads. Use `node/workload` when a name resolves to different identities on different nodes.
- `allow.groups`: named SPIFFE identity lists in `realm.authorization.groups`.
- `allow.identities`: explicit SPIFFE URIs, including external callers.

The receiver needs a nonempty final policy. Unknown references and groups fail validation. A Unix `peerUser` still requires one authorized identity and a dedicated unprivileged account. Workloads that share a SPIFFE ID share its permissions.

Legacy `target`, `native`, `privateLoopback`, `hostLoopback`, `backendUser` and `allowedIDs` remain available for existing integrations. Use one backend declaration style per ingress. The current service profiles use typed backends.

### Endpoint identities

Each publication records `unit`, `address`, `port`, `serverID`, `allowedIDs` and `transport`. Publishers supply the identity. DNS generates address records from this catalog but does not supply trust decisions.

An egress normally declares only `service` and optional `localPort`. Use `node` to select a publisher when the service has multiple endpoints. Unknown or ambiguous endpoints fail validation. An explicit `verifyID` must match the published identity.

A manual `target` remains supported. It uses an explicit identity or the selected publisher's identity. This override can select an external endpoint or a test fixture. Its actual receiver policy cannot be inferred from the catalog.

### HTTP gateways

All option paths below start at the NixOS configuration root.
`realm.http.gateways.<gateway>` defines a shared HTTPS gateway.
`realm.workloads.<workload>.http` declares one application's HTTP access.

For Internet access, set:

```nix
realm.workloads.example.http.internet = true;
```

This generates an `internet-proxy` egress and uppercase and lowercase proxy variables.
Applications with their own proxy settings still need those settings.
The Internet gateway must also admit the application's SPIFFE identity.

For internal HTTPS access, the site defines this gateway:

```nix
realm.http.gateways.eihort.hosts = config.data.serviceHosts.eihort;
realm.http.gateways.eihort.service = "https-gateway";
realm.http.gateways.eihort.admission = "declared-clients";
```

`realm.http.gateways.eihort.service` names one shared Realm catalog listener.
On eihort, `https-gateway` listens on port 19443 and forwards to Caddy's HTTPS port 443.
Caddy selects the business service from the HTTPS hostname.
One Realm listener can therefore carry requests for multiple domains.
The separate `internal-https` listener on port 19444 admits public Caddy entrypoints.

An application selects the gateway and declares its local hostname aliases:

```nix
realm.workloads.example.http.gateway.ref = "eihort";
realm.workloads.example.http.gateway.resolveHosts = [
  "oidc.nyaw.xyz"
  "s3.nyaw.xyz"
];
```

`realm.workloads.example.http.gateway.ref` selects the definition at `realm.http.gateways.eihort`.
`realm.workloads.example.http.gateway.resolveHosts` maps these names to `127.0.0.1` inside the application and adds proxy bypass entries.
Both names use the same private port 443 adapter and authenticated Realm channel.
The application's HTTPS connection retains its original hostname and certificate check.
These requests bypass the Internet proxy but still cross a Realm egress proxy.
Each alias must belong to the selected gateway's `realm.http.gateways.eihort.hosts` list.
One workload can select one internal HTTPS gateway on private port 443.

The aliases do not filter the HTTP Host header or authorize individual domains.
Realm authorizes the connection to the shared gateway listener.
Caddy and the backend application enforce any additional domain, path or application permissions.

`realm.http.gateways.eihort.admission` controls how the gateway client list is generated:

- `"explicit"` uses `realm.http.gateways.eihort.allowedIDs`.
- `"declared-clients"` also collects the identities of enabled workloads that select `"eihort"` through `realm.workloads.<workload>.http.gateway.ref`.

The site selects `"declared-clients"` explicitly.
It computes `realm.http.gatewayClientIDs.eihort` during Nix evaluation.
The receiver at `realm.workloads.caddy.ingress.https.allow.identities` uses that list plus its explicit additional identities.

### Containers

A container workload declares `container.name` and `container.backendPath`. The shared adapter generates its egress routes, optional SOCKS route, and helper, health script and socket mounts. `container.extraRoutes` describes additional sockets already mounted into the container, such as PostgreSQL.

The application profile retains its image, entrypoint, command, user mapping, environment, writable data paths and health check. Each OCI instance belongs to one Realm workload. Local route ports must be unique.

A custom egress socket uses a read-only mount of its parent directory so socket replacement remains visible. Select a directory dedicated to that route. Other accessible entries in that directory are also visible inside the container.

### Authorization reports

Inspect the receiver table and local outgoing connections:

```sh
nix eval --json .#nixosConfigurations.eihort.config.realm.authorization.matrix
nix eval --json .#nixosConfigurations.eihort.config.realm.authorization.connections
```

The receiver table contains the final listener identities and grants. The connection report compares each caller with those grants. Manual targets have an unknown authorization result, represented by `null`.

These reports describe identity admission. Caddy path rules, Envoy destination restrictions, database roles and application permissions still apply separately.

The current Azasos Caddy declares Atuin and Rustypaste egresses that their receivers do not admit. The report marks both connections as denied. Their existing receiver policies remain unchanged.


## Workload declarations

Keep declarations next to their service configuration in `mod/`.
The interface is in `nixosModules/realm-workloads.nix`, and its compiler is in `lib/realm/`.
SPIRE configuration and enrollment are in `nixosModules/realm-spire.nix`.

Migrated cluster service profiles require realm and have no legacy network
fallback. The reusable modules retain `realm.enable` as their activation
switch. Host-specific Caddy ingress and egress declarations live in
`mod/caddy/<hostname>.nix`; eihort's routes are declared in `mod/caddy/eihort.nix`.

```nix
realm.workloads.example = {
  unit = "example.service";
  user = "example";
  group = "example";

  egress.loki = {
    service = "loki";
    localPort = 13030;
  };

  ingress.http = {
    port = 18080;
    backend = {
      kind = "private-tcp";
      port = 8080;
    };
    service = "example";
    allow.identities = [ config.realm.caddy.localID ];
  };
};
```

`localPort` is optional. Applications supporting Unix clients can connect
directly to `/run/realm/example/egress/loki.sock`. TCP-only applications use
the loopback adapter in their private namespace. Neither path gives the
application a route to the host or the Internet.

The generated namespace holder starts before sockets.target. systemd owns
the workload-facing sockets; systemd-socket-proxyd bridges private loopback and
Unix sockets. No application needs to implement systemd socket activation.

Application units receive a private `/run` containing their egress directory,
declared runtime directories, credentials, the immutable system profile and
the systemd notification socket. Other runtime sockets are hidden. Add
necessary application runtime directories with `isolation.runtimePaths` and
additional local IPC with `isolation.allowUnixSockets`. Do not expose the
SPIRE Agent socket to an application using proxy mode.

Each workload has a separate proxy account. Its SPIRE registrations require
both the actual proxy/helper systemd unit and its Unix user. The default
SPIFFE ID is `spiffe://nyaw.xyz/service/<workload>`. Caddy uses
`spiffe://nyaw.xyz/service/caddy-<host>`. Its receiver policies live in
`mod/realm-caddy-policy.nix` and admit only the nodes that need each route.
Other instances that share an ID still share authorization. Root on a node remains trusted.

An ingress requires an explicit nonempty receiver policy. Declaring an
egress does not grant access at the receiver. ghostunnel enforces connection
authorization; database roles and HTTP operation/tenant authorization remain
application responsibilities.

## Direct TLS connections and CoreDNS

The ghostunnel client connects directly to the receiver's mesh address and port.
Nix gets that destination from `realm.serviceDiscovery.catalog`, the same catalog
that generates the CoreDNS zone. No Caddy SRV connector or discovery socket sits
between the two ghostunnel processes. The client checks the published
`serverID` or its explicit `verifyID` override. The receiver checks its final caller policy.

A service must have exactly one selected catalog endpoint unless its egress declares an
explicit `target`. The optional `node` selector narrows the catalog search. Missing or multiple endpoints fail configuration validation.
There is no runtime endpoint selection, SRV cache or automatic failover.
Address and port changes require deployment to the affected clients.

CoreDNS continues to serve the complete immutable `mesh.nyaw.xyz` zone on
loopback UDP/TCP 8600. Node AAAA records come from `registry.toml`. Ingress
AAAA and SRV records come from the catalog. systemd-resolved retains its suffix
delegation, and `/etc/coredns/mesh.zone` remains available for inspection.
Stopped services remain in the zone. DNS publication does not imply readiness.

Certificates and ghostunnel connections have a one-hour maximum lifetime.
Removing a SPIRE entry does not immediately close an established connection.
Restart the affected ingress when a policy change must close its connections.

ghostunnel drains open connections on `SIGTERM`, and an idle keep-alive
connection waits for that one-hour limit. The module therefore passes
`--shutdown-timeout 15s`, so a restart finishes in seconds instead of hitting
systemd's stop timeout and being killed. A restart drops connections that are
still open after those 15 seconds.

## PostgreSQL peer authentication

PostgreSQL runs in a private network namespace with `listen_addresses = ""`.
Its shared Unix socket remains at `/run/postgresql/.s.PGSQL.5432`.
No TCP HBA rules remain. Existing database passwords can remain stored, but
peer authentication does not use them.

Same-host applications mount `/run/postgresql` read-only. PostgreSQL checks the
connecting Unix user. Narrow peer maps retain the existing database roles:

| Consumer Unix user | Database | SQL role |
| --- | --- | --- |
| `vaultwarden` | `vaultwarden` | `vault` |
| `misskey` | `misskey` | `misskey` |
| `seaweedfs` | `seaweedfs` | `seaweed` |
| `atuin` | `atuin` | `atuin` |
| `immich` | `immich` | `immich` |
| `pocket-id` | `pocketid` | `pocket-id` |

The general `local all all peer` rule remains for other local applications.
Database grants still control access to tables and other databases.

Misskey keeps its existing loopback database address inside its rootless
container. Its helper connects that address directly to the mounted PostgreSQL
Unix socket as the host `misskey` user. No database ghostunnel or secret rewrite
is required.

Remote Autopeer instances retain the mTLS ingress `postgresql-autopeer` on
15438. Its dedicated `realm-pg-autopeer` Unix account maps to SQL role `dn42`
for the listed Autopeer databases. Removing same-host TLS changes the identity
check from a SPIFFE proxy to the kernel's Unix peer credentials. It does not
grant a compromised application another application's Unix identity.

## Unix backend listeners

Forgejo, Grafana, Calibre-Web, Synapse, ntfy and mautrix-telegram serve native
Unix sockets. Their ingress proxies receive only the group access needed to
connect. Synapse has separate HTTP and metrics sockets. ntfy uses a Unix
business socket and retains a separate private TCP adapter for metrics.

TCP-only applications retain `backend.kind = "private-tcp"` adapters in their private
network namespaces. These adapters remain necessary for Atuin, Vaultwarden,
Immich and other backends without a verified Unix listener.

## Existing service profiles

The current migration covers Alloy, Loki, PostgreSQL, Atuin, Misskey, its
Redis instance, Meilisearch, SeaweedFS, Grafana and Immich (including Redis,
machine learning and public proxy). Caddy accesses migrated
backends over its own authenticated egress sockets. The legacy SeaweedFS
metrics job uses vmagent's `__unix_socket__` label to scrape through its
authenticated egress.

Caddy is a systemd edge workload with host networking and a private `/run`
view. Its management API listens on `/run/caddy/admin.sock` (0600), inside a
0700 directory. Only its own egress directories, runtime directory and DNS resolver sockets are exposed. The Internet gateway is a separate Envoy process.
vmagent keeps its existing network access while its other monitoring targets
are migrated; its SeaweedFS egress is already authenticated. These exceptions
use `isolation.privateNetwork = false` explicitly; the Internet gateway and vmagent
also use
`runtime = "external"`.
Services without migration profiles and VM guests keep their previous isolation.
BIRD, Yggdrasil and VXLAN keep their current network configuration.
The existing recursive DNS module is separate from mesh discovery.

Public entrypoints (abhoth, nodens and azasos) import
`mod/caddy/public.nix`. Shared HTTP routes use Caddy's authenticated Unix
egress sockets, with direct catalog destinations and fixed remote SPIFFE IDs. Legacy routes
for seed, Memos, Alertmanager and heartrate cross the mesh through
eihort's separately authorized `internal-https` ingress (19444); their final
legacy backend connections are unchanged. The `https-gateway` ingress (19443)
serves application clients through the shared HTTPS listener. The zone apex reaches Misskey directly via
its own ingress and still serves Matrix discovery responses.

Yidhra has fixed 457 MiB memory and uses a smaller edge profile: local TLS
and Autopeer remain, while shared Web routes use one authenticated
`public-http` egress. Eihort serves that public route set on a separate
Unix socket behind ingress 19445. It preserves public route authentication
and trusts forwarded client headers only on that protected Unix listener.
Unknown hostnames receive 404. Yidhra sets Go memory tuning to a 48 MiB
soft limit and GOGC=50; these are not a hard process memory limit.

Rustypaste, ntfy and subs run in private loopback namespaces. Their business
ingresses allow only Caddy. ntfy's metrics use a separate ingress authorizing
only the local observation gateway. ntfy and subs fetch public HTTP(S)
resources through the authenticated Internet gateway. Subs uses a dedicated
account and receives its secret script via `LoadCredential`, rather than
running as the administrator.

Autopeer retains host netlink/WireGuard access and its PostgreSQL egress. Its
node-specific HTTP ingress authorizes Caddy; the original API binds only 127.0.0.1. Stalwart retains public mail networking,
but its Web API is exposed through the authenticated `stalwart-web` listener
on the observation gateway. That business listener rejects metrics/debug paths.
Public Caddy nodes without a local Rustypaste or Stalwart use their advertised
ingresses, rather than stale localhost routes. Xray and Hysteria retain their
gateway networking with process/filesystem sandboxes; a normal Hysteria server
no longer receives NET_ADMIN, NET_RAW, BPF or PERFMON capabilities, or realtime
CPU priority.

Misskey uses rootless Podman with `network=none`. Its UID/GID 1000 maps to
the host misskey account using keep-id. The realm helper adapts PostgreSQL through the mounted database socket. It
adapts Redis, Meilisearch, S3 and HTTP proxy connections through egress sockets. The application serves its native Unix socket; no host application
port is published. The container receives neither SVID keys nor the Agent
socket. The official image's tini entrypoint and migrateandstart command are
preserved. Verify the actual deployed image when upgrading the existing
`latest` tag.

The container health probe is `node /realm/health.cjs`, a script mounted next to
the helper: it requests `/health` on `REALM_HEALTH_PORT`, or the mounted backend
socket at `/`, and treats any response below 500 as healthy. It runs on the
image's own Node runtime so the check can be extended without giving the static
helper a probing surface; an image with neither a shell nor Node would need a
separate static prober instead.

Immich uses separate private namespaces for `immich-server`, `redis-immich`,
`immich-machine-learning` and `immich-public-proxy`. The server connects to
PostgreSQL through `/run/postgresql`. Redis on 127.0.0.1:6379 and ML on
127.0.0.1:3003 still use authenticated egress adapters. ML runs as the
separate `immich-ml` user; its HTTP/HTTPS proxy on 127.0.0.1:13128 reaches the
Internet gateway under the ML SPIFFE identity. Xet downloads are disabled;
verify model downloading and inference with the installed model versions.

Immich retains `settings = null`. Before deployment, set its persisted
`machineLearning.urls` setting to `[ "http://127.0.0.1:3003" ]` through the
administration UI. Do not rely on `IMMICH_MACHINE_LEARNING_URL` alone.
`photo.nyaw.xyz/share` and `/share/*` use the public proxy, including its static assets and media paths. Other paths use the main Immich server. The private eihort listener has no Caddy Basic Auth. Public entrypoints and the public relay require Basic Auth for the main server. Share paths remain public. Both entrypoint types use `caddy/immich.nix` to keep their path selection consistent. Immich's own authentication remains unchanged.
The public proxy connects to its own 127.0.0.1:2283 adapter.
Its existing Vaultix file contains only a database password and is unchanged;
the Unix peer connection does not use that password. SMTP, OAuth and
other optional server-side network integrations require separate egress
declarations when enabled. Check database extension upgrades and backup
privileges separately from the SPIFFE/peer authentication path.

Internet access uses Envoy's dynamic forward proxy and CONNECT termination.
Envoy is the native SPIFFE ingress on port 19328, registered as
`internet-proxy`. Each Realm node runs a gateway. Both generated and manual
`internet-proxy` egress declarations select the local node by default. An explicit
`egress.<route>.node` can override that default. Clients retain their local proxy
addresses, and the gateway uses the host's existing DNS and Internet routes.
The shared caller allowlist and CONNECT port rules remain the same on every node.
Local target selection does not restrict the listener to local callers or add
automatic fallback to another gateway. SPIRE supplies
its SVID and trust bundle through SDS. Updates apply to new connections without
restarting the gateway or writing private keys to disk. The listener requires
a client certificate whose URI SAN matches an exact ingress `allowedIDs` entry.

The gateway permits public destinations without a domain allowlist. CONNECT
preserves application TLS. The DNS cache removes private, loopback, link-local,
multicast and Yggdrasil addresses from DNS answers. RBAC checks the saved
resolved address and the selected upstream address, including IP literals.
Private IPv4-mapped IPv6 destinations are also blocked. CONNECT permits port 443, with port
8448 also permitted for the Synapse identity. Ordinary HTTP proxy requests
permit ports 80 and 443. The listener waits for SDS credentials before it
accepts connections. DNS publication does not wait for this readiness.
Misskey's only proxy bypass is s3.nyaw.xyz, which uses its local adapter to the
internal Caddy gateway.

`mod/overlay.nix` exports and applies `overlays.envoy`. The package in
`pkgs/by-name/envoy-realm.nix` pins Envoy 1.40.0 release binaries and hashes for
x86_64-linux and aarch64-linux. The optional local Nix cache adapter is also
configured for Envoy.
Static gateway configuration changes restart `realm-internet.service`.
Certificate updates use SDS and do not need a configuration reload.

## Vaultix

Loki and Misskey read complete configurations from Vaultix without a runtime
merge step. Update their decrypted YAML with the networking settings below,
then re-encrypt it into `sec/loki.age` and `sec/misskey.age` before deployment.
Local working copies in `plaintext-secret/` are ignored by Git and must stay
outside the Nix store. Credentials and unrelated settings are preserved.

For Loki, set `server.http_listen_address` and
`server.grpc_listen_address` to 127.0.0.1, and set
`common.storage.s3.endpoint` to 127.0.0.1:18333 with `insecure=true`. That
local plaintext hop is protected by the private namespace; inter-node
transport remains authenticated TLS. The S3 keys, bucket and region remain
in the encrypted secret. systemd passes the complete file through
`LoadCredential`; Loki reads `/run/credentials/loki.service/config`.

For Misskey, select the native Unix listener `/realm/backend/http.sock` and
mode 0660, remove the TCP port, change database/cache/search hosts to loopback
adapters, set `proxy=http://127.0.0.1:13128`, restrict `proxyBypassHosts` to
s3.nyaw.xyz, and limit
`allowedPrivateNetworks` to loopback. Database and search credentials remain
in Vaultix. With keep-id, Misskey's source secret can use mode 0400 instead
of 0444. Podman mounts this file read-only as `/misskey/.config/default.yml`.

Grafana's secret key and SeaweedFS's S3 configuration use systemd credentials.
Existing Grafana data sources saved in its database may need their URLs
updated. The provisioned Loki source uses http://127.0.0.1:13030. The
provisioned VictoriaMetrics source uses http://127.0.0.1:13090, which reaches
an authenticated API listener rather than the plaintext mesh port.
Grafana itself uses its local PostgreSQL peer socket. systemd unsets the legacy
`GF_DATABASE_URL` from its environment file so it cannot override that socket configuration;
the other secret environment settings remain available. Loki's instance, memberlist
and frontend addresses are explicitly loopback, avoiding host interface discovery.

## Pocket ID

The public OIDC route still reaches eihort through `internal-https`. Eihort Caddy
then uses its dedicated `pocket-id` egress. Pocket ID's business ingress accepts
only `caddy-eihort` and forwards to `/run/pocket-id/http.sock`. The application
runs in a private network namespace and shares no Workload API socket.

The existing `pocketid` PostgreSQL database and encryption key remain in use.
The last generated settings file overrides the old TCP database URL with the
Unix socket URL. Unix user and SQL role are both `pocket-id`, so the general
peer rule applies without a name map. The database remains named `pocketid`.
After deploying this URI, remove the temporary role-migration override
`/run/systemd/system/pocket-id.service.d/90-role-rename.conf` and its environment
file `/run/pocket-id-role-rename.env`, then run `systemctl daemon-reload`.
These runtime files bridge the live role rename until the generated unit is updated.
No database copy or encryption-key change is part of this migration.

The persisted SMTP address `box.nyaw.xyz:465` resolves to its local adapter only
inside the workload. The adapter uses the authenticated Stalwart ingress, and
application TLS still checks `box.nyaw.xyz`. HTTP(S) requests use the Internet
gateway. LDAP is not enabled and receives no route. Prometheus remains on
private loopback 9464, behind a separate observation-only ingress.

## Native certificate consumers

An application implementing SPIFFE TLS itself can declare
`ingress.<name>.backend.kind = "native"`, omitting the proxy address. The module binds
the workload's SPIRE registration to its application unit and Unix user,
grants access to the Agent socket, and publishes its ingress in the generated DNS zone.
The application must configure its own listener, consume SDS updates and
enforce the declared `allowedIDs`; the Internet gateway reads those declarations
directly. Native ingress currently requires a host-networked application.
The PEM credential adapter was removed. Applications on the proxy path receive
neither a private key nor the Workload API socket.

## Initial enrollment and deployment

See [the first deployment runbook](realm-deployment.md) for the host order,
bootstrap commands, secret prerequisites and application checks.

The SPIRE signing keys and datastore are persisted under /var/lib/spire;
enrollment material is root-only under /var/lib/realm-spire. Include these
paths in the host's normal persistence and backup strategy. Neither belongs
in Git or the Nix store.

Deploy eihort first so the Server and registration reconciler exist. Initial
workload starts can fail until the Agent is enrolled. Enrollment is carried
over the existing root SSH trust boundary:

```sh
ssh root@eihort realm-enroll eihort | ssh root@eihort realm-install-enrollment
ssh root@eihort realm-enroll abhoth | ssh root@abhoth realm-install-enrollment
```

Each command issues a short-lived, single-use token and transfers the public
trust bundle directly to its destination. Do not print or save the enrollment
JSON in a public log. Enroll each deployed mesh node and restart any failed
workload units. Registration entries are generated from workload declarations
across hosts, reconciled idempotently by `realm-helper spire-register` and
pruned only from that reconciler's own managed set.

Agent keys survive a restart. If an Agent's cached node identity expires
while it is offline, join-token attestation requires fresh enrollment. The
enrollment tools are administrative commands, not workload capabilities.

## Verification

The refactor comparison covered 550 related units on eight Realm nodes. Unit names, SPIFFE registrations, identities, listener addresses, ports and socket paths stayed unchanged. Receiver grants stayed unchanged. Container mount sets and route files also stayed unchanged.

Seven application units gained lowercase proxy variables with the same values as their existing uppercase variables. Three dependency lists changed order. Misskey's mount order changed, which changed its generated start script path. The mount set and application command stayed unchanged.

The refactor passed the networking, container, Immich and actual-service integration suites. The networking suite reused its previous successful output because its generated VM derivation stayed identical. The other three suites ran their VMs again. Cluster, backend, identity and HTTP evaluation tests also passed.

These checks did not deploy the refactor to production nodes. The independent Shellbox change made during the comparison was excluded from Realm container comparisons.

`tests/realm-model.nix` checks typed backends, identity references and endpoint selection.
`tests/realm-cluster.nix` checks cross-node aggregation, receiver admission and disabled workloads.
`tests/realm-workloads.nix` checks evaluation and legacy policy wiring.
`tests/realm-vm.nix` checks actual SPIRE enrollment, direct TLS connections, authorized
and rejected mTLS peers, PostgreSQL peer authentication, socket isolation,
Internet proxy destination restrictions and registration
reconciliation. `tests/realm-immich.nix` imports the actual Immich, PostgreSQL
and Internet gateway profiles with fixture application processes, real
PostgreSQL/Redis and real SPIRE. It checks dependency forwarding, peer role
isolation, rejected SPIFFE callers, ML gateway authorization and private
runtime/network boundaries. It does not exercise Immich's actual migrations,
model downloads or inference. `tests/realm-container.nix`
checks the rootless container socket adapters with a dummy image and dummy
credentials. It does not replace checking the actual Misskey image on eihort.

## Application profiles and observation endpoints

Synapse and mautrix-telegram have separate private network namespaces. The
bridge's homeserver requests and Synapse's appservice callbacks use independent
SPIFFE routes. Both retain local PostgreSQL Unix peer authentication. Synapse's
S3 backend and scheduled uploader use authenticated SeaweedFS routes. Calibre
accepts requests only from Caddy's SPIFFE identity.

Mautrix Telegram MTProto connections use a private SOCKS5 adapter, chained to
that workload's authenticated HTTP Internet egress. `socksProxy.enable` adds
this adapter for applications requiring SOCKS; container workloads receive it
through an additional protected Unix socket. UDP and SOCKS BIND are disabled.
The gateway permits public HTTP/HTTPS destinations; only the Synapse identity
also receives CONNECT access to public port 8448 for federation. Federation
servers advertising other custom ports require an explicit gateway policy.

Telegram Search is enabled on eihort as a rootless `network=none` container.
Its frontend publishes a Unix socket to Caddy; database access uses a dedicated
PostgreSQL ingress and peer role mapping. S3 TLS is preserved through Caddy's
S3 ingress. GramJS uses the SOCKS adapter; Node HTTP requests use environment
proxy support. The image's nginx worker setup retains CHOWN/SETUID/SETGID only
inside the rootless user namespace. Its nginx state/log directories use disposable
tmpfs mounts with `notmpcopyup`, so restrictive ownership from the image is not copied
into those mounts and no DAC override capability is needed. Existing `/var/lib/tg-search` data ownership
is migrated once to the rootless service account. The existing upstream
`latest` image tag is retained; fixture tests do not validate a future image's
layout or behavior. ARTEX and Magpie are outside this migration.

Each exporter declares its endpoint next to its service via
`realm.observability.endpoints`. Caddy publishes one mTLS observation ingress
per host, with a host-specific SPIFFE identity and a vmagent caller allowlist.
CoreDNS advertises that ingress. Vmagent uses protected Unix egress sockets,
validates the expected host identity, and requests only `/NAME/metrics` or the
explicitly configured `/NAME/probe` routes. Business and debug paths, metrics
query parameters, and non-GET methods are rejected. Blackbox probe module and
target pairs are enumerated from the configured jobs; extra and duplicate
parameters are rejected. Redirects are disabled for HTTP probes.

The gateway uses `caddy-realm` with the published SPIFFE plugin. The
`tls.get_certificate.spiffe` module serves the current SVID from the Workload
API. The `tls.client_auth.verifier.spiffe` module verifies client SVIDs against
the current trust bundle and the listener's exact identity allowlist. Each TLS
policy uses `mode = "require"` without a static CA pool. The verifier checks
both the certificate chain and the client-auth purpose before it accepts an
identity. SVID and CA updates need no reload or Caddy source patch.

Public paths name exporter endpoints. A URI rewrite restores the exporter's
own `/metrics` or `/probe` path before proxying and keeps the probe query string.

The observation gateway keeps its own process, `realm-observability.service`,
rather than merging into the public Caddy instance. One process holds one SPIFFE
identity, and this identity is authorized for observations only: sharing the
public gateway's identity would let a compromise of one role impersonate the
other, and would require the Agent to serve two SVIDs to the same unit.

Exporter listeners bind loopback where supported. An input firewall rule
additionally blocks external access to backend metric ports. NCPS runs in a
private namespace; its cache ingress accepts only the Nix cache client identity.
Its metrics use a separate observation-only ingress. The previous plaintext
port 8501 is no longer exposed. VictoriaMetrics keeps
a filtered mTLS listener for its existing query/write port;
those business APIs retain their previous mesh access policy. It also publishes
an authenticated API listener. That listener rejects metrics/debug paths,
preserves other business paths and methods, and admits only the identities in
`businessAllowedIDs`; Grafana queries it through a protected Unix egress socket.
Both listeners are separate ports, so the plaintext business port keeps its
path restrictions. Vmagent and
vmalert HTTP listeners bind loopback. Alertmanager HTTP binds loopback and its
public Caddy route excludes metrics/debug paths; cluster gossip is unchanged.
Stalwart's public Caddy route also excludes its metrics/debug paths. Synapse
metrics traverse a dedicated authenticated ingress after leaving its private
namespace. Sept guest exporters use the host observation ingress, with the
final connection confined to the existing guest bridge. Node and chrony
exporters keep host visibility; infrastructure daemon networking is unchanged.

`tests/realm-vm.nix` also tests the SOCKS chain, Synapse-specific federation
permission, observation identity checks, path/query restrictions, blackbox
allowlists, the shared business listener, the authenticated API listener with
its caller allowlist, and direct backend firewall denial.
`tests/realm-container.nix` imports both actual Misskey and Telegram Search
profiles with a fixture image, including the latter's TCP-to-Unix ingress,
rootless mapping, environment override, health check and the socket-activated
SOCKS bridge.


Jellyfin, Vaultwarden, Forgejo and NCPS are isolated workloads declared in their
own `mod/` service profiles. Caddy reaches the application HTTP backends through Unix
mTLS egress sockets; NCPS instead accepts the dedicated Nix cache client. Their public Internet requests use the authenticated
Internet gateway; Forgejo explicitly enables its application proxy and also sets
libcurl proxy variables for Git subprocesses. Jellyfin media paths and device
permissions are preserved; LAN discovery and direct media ports do not cross
its private network namespace.

Forgejo and NCPS retain their local PostgreSQL peer sockets. Vaultwarden's final
environment file selects the mounted Unix socket. Its peer map accepts Unix
user `vaultwarden` as SQL role `vault` in database `vaultwarden`.
PostgreSQL TCP listeners and SCRAM HBA entries are removed.

SMTP for Forgejo and Vaultwarden uses Stalwart's SPIFFE-authenticated
`smtp-submission` ingress. S3 for Forgejo and NCPS uses Caddy's authenticated
S3 ingress. Workload-local `/etc/hosts` aliases direct the original SMTP/S3
hostnames to the local adapters, preserving application TLS verification and
SNI. These aliases do not change host-wide DNS. No migrated profile needs a
resolver: every outbound name is either aliased here or resolved by the gateway
on the far side of a CONNECT request. The unused private DNS relay
was removed. CoreDNS and the host resolver remain available to infrastructure.
No secret values need changing.
Stalwart keeps its public mail edge networking. The existing Forgejo Actions
runner remains a separate execution boundary with its existing container
runtime access; the Forgejo daemon's private namespace does not isolate CI
jobs or remove runner privileges.

`tests/realm-services.nix` runs the actual Jellyfin, Vaultwarden, Forgejo and
NCPS executables with real PostgreSQL and SPIRE. Local SMTP/S3 fixtures
supply dummy credentials and certificates. It checks application startup,
authenticated ingress, SMTP/S3 certificate names, PostgreSQL role isolation,
NCPS observation, FFmpeg proxy requests, hidden runtime sockets and blocked direct network access.
It does not exercise real SMTP delivery, S3 durability or CI jobs.


The `ncps-client` module is wired into realm hosts. It exposes only a loopback
adapter at `http://127.0.0.1:18502`, permitting GET/HEAD cache reads and rejecting
metrics/debug paths. It forwards to NCPS with the `nix-cache`
SPIFFE identity. NCPS has no new public Caddy route and its old mesh plaintext
port remains closed. Nix substituter use remains opt-in (the existing commented
entry in `mod/nix.nix` now points to this adapter). This grants Nix a cache
capability without changing the Nix daemon's host infrastructure permissions.

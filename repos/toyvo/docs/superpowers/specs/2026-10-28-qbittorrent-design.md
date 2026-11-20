# qBittorrent migration to k3s (VPN-isolated pod) — Short Design

Date: 2026-10-28
Status: proposed, awaiting approval
Approach picked: WireGuard + qBittorrent + port-forward sidecars in one
pod, iptables kill-switch, Proton DNS, SecretSpec-managed key

## Intent / why

qBittorrent is the last workload in a NixOS container. Moving it
into k3s removes the container runtime from the media stack
entirely (module, netns wiring, socket proxy, NAT exception) and
puts the downloader on the same template, networking, and
observability as everything else. The k8s shape is *simpler* than
the container in one dimension (no namespace-bridging socket
proxy) at the cost of the cluster's first privileged pod.

## Goals

- qBittorrent in k3s as a StatefulSet pinned to nas:
  - `wireguard` container (pinned image, `wg0.conf` from a
    SecretSpec-managed k8s Secret, ProtonVPN endpoint).
  - `qbittorrent` container (linuxserver image pinned, PUID/PGID
    matching existing  `qbittorrent` ids, config on local-path
    claim, downloads to existing `/mnt/Downloads` via RW media
    PVC).
  - `port-forward` container/loop (NAT-PMP via Proton gateway
    every 45s, pushing the mapped port to qbit's localhost API —
    same logic as today, easier: shared localhost, and
    `LocalHostAuth=false` is already set).
  - iptables kill-switch in an initContainer (`NET_ADMIN`):
    default DROP, holes only for the WireGuard handshake
    (UDP to the Proton endpoint), loopback, cluster CIDRs
    (probes, Traefik, CoreDNS if used), and `-o wg0` established
    tunnel traffic.
- DNS through the tunnel: `dnsPolicy: None` with the Proton
  gateway resolver, so tracker lookups never leak to LAN/ISP.
  Fails closed with the tunnel by construction.
- SecretSpec contract: ProtonVPN private key (+ wireguard
  endpoint/public key if not hardcodable) in the Proton Pass
  `secretspec` vault, `refs.kube` pinned, Secret mounted as
  `wg0.conf`. Same alias-invocation discipline as homepage.
- In-app reconfiguration (user, in each *arr UI): download client
  URL `http://10.200.0.2:4080` → cluster address
  (`http://qbittorrent:4080` preferred — no Caddy round-trip;
  public URL as fallback). Applies to sonarr/lidarr/radarr/readarr.
- Ingress `qbittorrent.diekvoss.net` + Caddy upstreams flip
  (forward-auth already off starr-wide).
- Old container qBittorrent stopped before k8s takes traffic (no
  dual-identity: same torrents + NAT-PMP port fights). Cutover is
  stop-old → verify-new, not parallel-run.

## Non-goals

- No changes to the six *arrs + prowlarr + flaresolverr beyond
  the download-client URL repoint.
- No deletion of the container module yet (follows after k8s
  qbit is proven stable; separate cleanup).
- No POOL state deletion, ever in this plan.

## Anti-goals

- Don't run two qBittorrents against the same state/torrents
  (port-forward conflicts, duplicate announces). Brief
  downloader downtime during cutover is accepted and preferable.
- Don't leak DNS outside the tunnel (the whole point of the VPN
  for this workload).
- Don't weaken the kill-switch for convenience (no 0.0.0.0/0 holes
  beyond wg0; cluster-CIDR holes documented and minimal).
- Don't hand-edit the container qbit config during migration
  (module regenerates it; declarative only — lesson learned).

## Constraints

- Node-pinned to nas (tunnel endpoint stability + state
  locality); local-path config volume (never NFS).
- Downloads reuse `/mnt/Downloads` (already declarative,
  already proven visible to all *arr pods).
- Pod needs `NET_ADMIN` (first privileged pod — explicit
  acknowledgment, documented in the manifests).
- Secret values never in the Nix store (SecretSpec path only).
- Manifest propagation lag + explicit pod deletion to recycle
  (established lessons).

## Approaches considered

- Sidecar pod with iptables kill-switch (picked): maps 1:1 onto
  the proven container semantics with one fewer moving part
  (no socket proxy), keeps Proton DNS posture.
- Node-level WireGuard + policy routing (rejected): spreads VPN
  state across host networking, affects all node traffic,
  harder to reason about and to roll back per-workload.
- Leave qBittorrent containerized forever (rejected by user:
  goal is zero NixOS containers in the media stack).

## Decided (what the builder implements)

- `modules/nixos/k3s-starr.nix`: add `qbittorrent` block —
  StatefulSet (1 replica, nodeAffinity nas, three containers +
  iptables initContainer, `dnsPolicy: None` + Proton DNS,
  local-path config claimTemplate + existing-pattern RW media
  PVC, secret volume for `wg0.conf`), Service ClusterIP :4080,
  Ingress class traefik host `qbittorrent.diekvoss.net`.
- `homelab.nix` `starr.services.qbittorrent.upstreams` set (dark
  until router switch).
- SecretSpec: new `k8s/qbittorrent/secretspec.toml` (or
  extension of the existing contract file) for the WireGuard
  key material; user loads values into Proton Pass first.
- Runbook (user executes): load secrets → switch nas →
  verify pod + kill-switch (see below) → STOP container qbit →
  seed config/state → repoint four download clients → trigger
  test download → verify lands in `/mnt/Downloads` and imports
  → flip (switch router) → verify incl. failover → confirm old
  port dead.
- Kill-switch proof (before trusting traffic): from the pod,
  `wg show` up; then stop the wireguard container (or `ip link
  set wg0 down`) and prove all egress fails while cluster-local
  still answers — the defining test of this migration.
- Rollback: re-enable container qbit (module still present),
  repoint clients back, scale StatefulSet to 0.

## Left to the builder

- Exact ProtonVPN endpoint IP/port + gateway for the iptables
  holes and DNS stanza (today: endpoint `79.127.187.156:5180`,
  gateway `10.2.0.1` — confirm still current at build time).
- Pinned image tags, hub-verified (linuxserver/qbittorrent +
  wireguard sidecar image choice).
- Whether port-forward is a third container or a loop in the
  wireguard container (builder picks; behavior identical).
- qBittorrent UID/GID (existing ids) for PUID/PGID + state dir
  seeding (config + fastresume continuity vs fresh start —
  recommend seeding live state like the *arrs).

## Verification bar

(1) pod Running on nas with all containers ready, (2) `wg show`
handshake + kill-switch fail-closed proof, (3) DNS egress
verified through tunnel (resolve a tracker hostname from the
pod and confirm the query path), (4) end-to-end download MANDATORY
here (not deferred — this IS the downloader; an import through
`/mnt/Downloads` into a library proves the whole chain),
(5) Caddy flip + failover, (6) old port quiet. No download
deferral: the standing deferral was for the *arrs, and Sonarr's
proof predates the DNS fix.

## Builder self-check (no subagent tool)

- No store-baked secrets. No dual-qbit operation.
- Kill-switch proof is the gate — everything else follows it.
- Download test mandatory (this workload's entire purpose).

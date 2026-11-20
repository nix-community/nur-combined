# Sonarr migration to k3s — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: same template as Prowlarr + one RW media PV

## Intent / why

Sonarr is the natural second domino: it talks to both already-moved
Prowlarr (indexer) and still-containerized qBittorrent (download
client), exercising the split-brain paths in both directions. Same
shape as Prowlarr otherwise — single SQLite config dir, linuxserver
image, hand-seeded data — plus one new requirement: Sonarr writes
into the media library on import, so this migration also proves the
RW side of the NFS storage platform.

## Goals

- Sonarr in k3s (linuxserver image pinned
  `lscr.io/linuxserver/sonarr:4.0.20.3014-ls329`, PUID/PGID 274 to
  match nixpkgs `ids.uids/gids.sonarr` and existing file ownership)
  as a StatefulSet pinned to nas, sqlite on local-path (never NFS).
- One new static PV `pool-media-rw` → `/mnt/POOL/Public`, RW,
  mounted at `/mnt` in the pod (mirrors the container's
  `mediaDir` bind). Existing `pool-public-ro` stays for readers.
- Data seeded by hand: copy `/mnt/POOL/starr/sonarr` into the
  provisioned local-path volume dir, rollout restart.
- In-app reconfiguration (user, in Sonarr UI): indexer URL →
  `https://prowlarr.diekvoss.net` (auth gate off, API key unchanged);
  download client URL → `http://10.200.0.2:4080` direct (bypasses
  Caddy entirely; LocalHostAuth=false already set on the container).
- Ingress `sonarr.diekvoss.net` + Caddy `upstreams` flip (same shape
  as Prowlarr; forward-auth gate already off per user's starr-wide
  change).
- Old container service disabled via `disabledServices` after k8s
  instance verified (import test: trigger a manual import or wait
  for a grab and confirm the file lands in the library).

## Non-goals

- No other *arr moves; no qBittorrent move (VPN entanglement —
  last, if ever).
- No secret work (API key rides inside the seeded config; homepage
  widget key unchanged).

## Anti-goals

- Don't put sqlite on NFS; don't change PUID away from 274.
- Don't break active downloads: qBittorrent stays untouched in the
  container; only Sonarr's pointers to it change.
- Don't regress Prowlarr (untouched; already flipped and verified).

## Constraints

- Local-path volume node-pinned to nas; media PV is Retain like the
  others (data preserved by design).
- The container and k8s instances must never run the same config
  simultaneously against the library (import collisions) — retire
  promptly after verify, same as Prowlarr.
- Pod egress to `10.200.0.2:4080` and `prowlarr.diekvoss.net` must
  work from the pod network (flannel egress masquerades as node IP;
  both targets are LAN-reachable; verify before flip).

## Approaches considered

- linuxserver image, same template (picked): identical shape to the
  proven Prowlarr move, one new PV for the one new requirement (RW
  media).
- Reuse `pool-public-ro` with a write sidecar (rejected): contortion
  for no benefit; a second PV for the RW mount is the honest shape.
- Move qBittorrent first (rejected): VPN netns + NAT-PMP + socket
  proxy is the hardest move in the stack, not the second-easiest.

## Decided (what the builder implements)

- `modules/nixos/k3s-starr.nix`: add `sonarr` block mirroring
  prowlarr (port 8989, image pinned above, PUID/PGID 274) plus a
  `config` volumeClaimTemplate (5Gi local-path) and a `media`
  volumeMount (`/mnt` ← PVC `sonarr-media`, 100Gi RWX `nfs-pool`).
- New static PV `pool-media-rw` (server 10.1.0.3, share
  `/mnt/POOL/Public`, RW, Retain, `nfs-pool`) in
  `k3s-storage.nix` (nas-applied, same file as the other PVs).
- `homelab.nix` `starr.services.sonarr.upstreams` set (dark until
  router switch).
- Runbook (user executes): switch nas → verify pod+PVCs → rsync
  `/mnt/POOL/starr/sonarr` into volume dir → restart → verify UI +
  API key → reconfigure indexer/download-client URLs in Sonarr UI →
  test a download end to end (grab → qbit → import → library file
  appears) → flip (switch router) → verify → retire container
  sonarr via `disabledServices`, switch nas.
- Rollback: revert Caddy flip, scale StatefulSet to 0, re-enable
  container service. POOL data never moved, only copied.

## Left to the builder

- Confirm 100Gi label sane for the media PVC (labels only, no quota
  enforced; keep consistent with pool-k3s-test 50Gi style).
- Confirm TZ + any env the linuxserver sonarr image needs beyond
  PUID/PGID (check image docs at build time; none expected).

## Builder self-check (no subagent tool)

- Prowlarr untouched (no manifest edits to its three files).
- Split-brain URLs documented with direction (pod→public prowlarr,
  pod→direct qbittorrent) and verified before flip, not assumed.
- No simultaneous-writers window: retire promptly after verify.

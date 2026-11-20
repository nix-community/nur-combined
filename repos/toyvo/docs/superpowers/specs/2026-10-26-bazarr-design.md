# Bazarr migration to k3s — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: same StatefulSet template, different wiring (API consumer of Sonarr/Radarr, not a download-client owner)

## Intent / why

Sixth and last *arr move. Bazarr is shaped differently from the
other five: it owns no download client and no indexer. Instead it
talks to the Sonarr and Radarr APIs (to discover media needing
subtitles) and scans the same library paths on disk. Everything it
depends on is already in k3s, so it comes last by construction.

## Goals

- Bazarr in k3s (linuxserver image pinned
  `lscr.io/linuxserver/bazarr:v1.6.2-ls369`, PUID/PGID 350 per
  nixpkgs `ids.uids/gids.bazarr`) as a StatefulSet pinned to nas,
  sqlite on local-path (never NFS).
- Media via the existing `pool-media-rw` PVC pattern (new
  `bazarr-media` PVC 100Gi RWX nfs-pool, same shared export, up
  front — no Pending dance).
- Data seeded from the verified-live set: locate the live state
  first with sudo (dir is permission-gated), `.backup` + integrity
  check + count before trusting it, `chown` to 350.
- In-app reconfiguration (user, in Bazarr UI) — the Bazarr-shaped
  part: Sonarr/Radarr API connections repointed from container
  localhost ports to the public k8s URLs
  (`https://sonarr.diekvoss.net`, `https://radarr.diekvoss.net`,
  API keys unchanged, seeded with config); library paths already
  `/mnt/...` on both sides (same shared export), confirm they
  resolve.
- Ingress `bazarr.diekvoss.net` + Caddy `upstreams` flip
  (forward-auth already off starr-wide).
- Old container service disabled via `disabledServices` after a
  successful in-app reconfiguration + UI verification (series list
  populated from Sonarr/Radarr); old port confirmed dead.

## Non-goals

- No new PV (reuse `pool-media-rw` with a per-app PVC — PVs bind
  1:1, established pattern).
- No secret work (keys ride with the seeded config); no other moves.

## Anti-goals

- Don't restart or otherwise touch the container Bazarr until k8s
  is verified (its live DB is the seed source).
- Don't run two Bazarrs against the same libraries (retire
  promptly after verify); don't touch `/mnt/POOL/Public` ACLs
  (pod runs as existing UID).
- Download test not applicable (Bazarr downloads nothing via
  qBittorrent; per standing decision no e2e downloads anyway).

## Constraints

- Local-path volume node-pinned to nas; RW media PVC on `nfs-pool`.
- Seed source = live set (verify with sudo `ls` first; backup +
  integrity + count).
- Split-brain checks from the pod before flip: Sonarr/Radarr API
  URLs reachable (same public-URL shape already proven from pods),
  `/mnt` library paths visible.
- Manifest propagation lag: allow minutes after switch; delete
  stale pods rather than waiting.
- Image tag already verified against hub API (v1.6.2-ls369).

## Approaches considered

- Same StatefulSet template (picked): sixth repetition of the
  proven shape; only the wiring (API peers, no download client)
  differs.
- Anything else (rejected): nothing about Bazarr's runtime needs
  differs (sqlite + /mnt + k8s networking).

## Decided (what the builder implements)

- `modules/nixos/k3s-starr.nix`: add `bazarr` block mirroring
  readarr (port 6767, image pinned above, PUID/PGID 350,
  `bazarr-media` PVC 100Gi RWX nfs-pool, `/mnt` mount,
  nodeAffinity nas, 5Gi config claimTemplate).
- `homelab.nix` `starr.services.bazarr.upstreams` set (dark until
  router switch).
- Runbook (user executes): switch nas → verify pod+PVCs → seed from
  verified-live set via sqlite backup → restart → verify series
  list populates in UI (proves Sonarr/Radarr API links + library
  scan) → split-brain connectivity checks → reconfigure in-app
  Sonarr/Radarr URLs → pod write test (`touch
  /mnt/.write-test`) → flip (switch router) → verify incl.
  failover → retire (`disabledServices` += bazarr, switch nas, old
  port dead).
- Rollback: revert Caddy flip, scale StatefulSet to 0, re-enable
  container service. POOL data never moved, only copied.

## Left to the builder

- Confirm Bazarr's live state dir layout on nas before seeding
  (sudo-gated).
- Confirm what the container Bazarr uses as Sonarr/Radarr
  addresses today (to know exactly what to repoint).

## Verification bar (agreed 2026-10-26)

Full end-to-end downloads are deferred across the *arr migrations
(indexers stale; rebuild later). Each migration proves instead:
(1) seeded library matches in the k8s UI, (2) split-brain API
reachability from the pod, (3) a real pod write to the library
path, (4) Caddy flip + failover, (5) old port quiet. Sonarr already
proved the full download loop once; that stands as the template's
import proof. For Bazarr, (1) = series/movies populated via the
Sonarr/Radarr APIs.

## Builder self-check (no subagent tool)

- No new PV, no new secrets, no new mechanisms.
- Image tag verified against hub listing before writing manifests.
- Download test not applicable (no download client).

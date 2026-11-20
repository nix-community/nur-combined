# Radarr migration to k3s — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: same template as Lidarr/Sonarr (biggest remaining library, hardest media-path exercise)

## Intent / why

Fourth starr move, biggest remaining library (Movies). Structurally
identical to Lidarr: single SQLite config dir, no VPN, API
relationships to already-moved Prowlarr and still-container
qBittorrent. Exercises the RW media path hardest of the three left.

## Goals

- Radarr in k3s (linuxserver image pinned
  `lscr.io/linuxserver/radarr:6.4.4.10685-ls324`, PUID/PGID 275 per
  nixpkgs `ids.uids/gids.radarr`) as a StatefulSet pinned to nas,
  sqlite on local-path (never NFS).
- Media via the existing `pool-media-rw` PVC pattern (new
  `radarr-media` PVC 100Gi RWX nfs-pool, same shared export).
- Data seeded from the verified-live set: locate the live `.db`
  first (Sonarr: top level was stale, live set was
  `.config/<App>/`; Lidarr: `.config/Lidarr/`), `.backup` +
  integrity check + count before trusting it, `chown` to 275.
- In-app reconfiguration (user, in Radarr UI): indexer →
  `https://prowlarr.diekvoss.net`, download client →
  `http://10.200.0.2:4080` (API key unchanged, seeded with config).
- Ingress `radarr.diekvoss.net` + Caddy `upstreams` flip
  (forward-auth already off starr-wide).
- Old container service disabled via `disabledServices` after a
  successful in-app reconfiguration + UI verification; old port
  confirmed dead. Full download test deferred (same as Lidarr:
  indexers stale, rebuild later; the import path was proven by Sonarr
  and the RW write path is verified per-migration).

## Non-goals

- No new PV (reuse `pool-media-rw` with a per-app PVC — PVs bind
  1:1, one RW PV per app, established pattern).
- No secret work (key rides with the seeded config); no other moves.

## Anti-goals

- Don't restart or otherwise touch the container Radarr until k8s is
  verified (its live DB is the seed source).
- Don't run two Radarrs against the library (retire promptly after
  verify); don't touch `/mnt/POOL/Public` ACLs (pod runs as
  existing UID).
- Download test deferred (same as Lidarr — indexers stale, rebuild
  later; Sonarr already proved the import path and each migration
  verifies an actual pod write to the library).

## Constraints

- Local-path volume node-pinned to nas; RWX media PVC on `nfs-pool`.
- Seed source = live `.config/Radarr/*.db` (verify with `ls` first;
  backup + integrity + count).
- Split-brain URLs identical in shape to Sonarr/Lidarr (public
  prowlarr, direct qbittorrent); verify from the pod before flip.

## Approaches considered

- Same template (picked): fourth repetition, no new mechanisms.
- Anything else (rejected): nothing about Radarr differs
  structurally from Sonarr/Lidarr.

## Verification bar (agreed 2026-10-26)

Full end-to-end downloads are deferred across the *arr migrations
(indexers stale; rebuild later). Each migration proves instead:
(1) seeded library matches in the k8s UI, (2) split-brain API
reachability from the pod, (3) a real pod write to the library
path, (4) Caddy flip + failover, (5) old port quiet. Sonarr already
proved the full download loop once; that stands as the template's
import proof.

## Decided (what the builder implements)

- `modules/nixos/k3s-starr.nix`: add `radarr` block mirroring lidarr
  (port 7878, image pinned above, PUID/PGID 275, `radarr-media` PVC
  100Gi RWX nfs-pool, `/mnt` mount, nodeAffinity nas, 5Gi config
  claimTemplate).
- `homelab.nix` `starr.services.radarr.upstreams` set (dark until
  router switch).
- Runbook (user executes): switch nas → verify pod+PVCs → seed from
  verified-live set via sqlite backup → restart → verify movie count
  in UI → split-brain connectivity checks → reconfigure in-app URLs
  → end-to-end download (grab → qbit → import → file in library) →
  flip (switch router) → verify incl. failover → retire
  (`disabledServices` += radarr, switch nas, old port dead).
- Rollback: revert Caddy flip, scale StatefulSet to 0, re-enable
  container service. POOL data never moved, only copied.

## Left to the builder

- Confirm Radarr's live state dir layout on nas before seeding.
- Confirm download test file lands under Movies.

## Builder self-check (no subagent tool)

- No new PV, no new secrets, no new mechanisms — pure repetition.
- Download test is mandatory this time (Lidarr deferred it; the RW
  path needs one proven import before readarr/bazarr).

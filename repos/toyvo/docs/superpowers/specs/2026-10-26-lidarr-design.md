# Lidarr migration to k3s — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: same template as Sonarr (Prowlarr established it, Sonarr extended it with RW media)

## Intent / why

Third starr move, identical shape to Sonarr: single SQLite config dir,
no VPN, API relationships to already-moved Prowlarr and still-container
qBittorrent. Only delta from Sonarr: different port/image/UID and the
Music library path (already covered by the existing RW `pool-media-rw`).

## Goals

- Lidarr in k3s (linuxserver image pinned
  `lscr.io/linuxserver/lidarr:3.1.6.5079-ls46`, PUID/PGID 306 to match
  nixpkgs `ids.uids/gids.lidarr` and existing ownership) as a
  StatefulSet pinned to nas, sqlite on local-path (never NFS).
- Media via the existing `pool-media-rw` PVC (`sonarr-media` proves
  the multi-claim pattern on one PV; add a `lidarr-media` PVC
  against the same PV — RWX allows it).
- Data seeded from the LIVE set via sqlite `.backup` + integrity
  check (lesson from Sonarr: never trust a hot file copy of the top
  level; verify show/artist count before and after).
- In-app reconfiguration (user, in Lidarr UI): indexer →
  `https://prowlarr.diekvoss.net`, download client →
  `http://10.200.0.2:4080` (API key unchanged, seeded with config).
- Ingress `lidarr.diekvoss.net` + Caddy `upstreams` flip
  (forward-auth already off starr-wide per user's change).
- Old container service disabled via `disabledServices` after an
  end-to-end download verified; old port confirmed dead.

## Non-goals

- No new PV (reuse `pool-media-rw`); no secret work (key rides with
  the seeded config); no other moves.

## Anti-goals

- Don't run two Lidarrs against the library (retire promptly after
  verify, same as Sonarr).
- Don't restart the container Lidarr until k8s is verified (its live
  DB is the seed source; lesson from Sonarr's 0-byte scare).

## Constraints

- Local-path volume node-pinned to nas; RWX media PVC on `nfs-pool`.
- Seed source = live `.config/Lidarr/*.db` set (verify location with
  `ls` before copying — Sonarr taught us the top level may not be
  the live set). `.backup` + `integrity_check` + count before
  trusting it.
- Split-brain URLs identical in shape to Sonarr (public prowlarr,
  direct qbittorrent); verify from the pod before flip.

## Approaches considered

- Same template as Sonarr (picked): no new mechanisms, third
  repetition proves the pattern is routine.
- Anything else (rejected): nothing about Lidarr differs
  structurally from Sonarr.

## Decided (what the builder implements)

- `modules/nixos/k3s-starr.nix`: add `lidarr` block mirroring sonarr
  (port 8686, image pinned above, PUID/PGID 306, `lidarr-media` PVC
  100Gi RWX nfs-pool, `/mnt` mount, nodeAffinity nas, 5Gi config
  claimTemplate).
- `homelab.nix` `starr.services.lidarr.upstreams` set (dark until
  router switch).
- Runbook (user executes): switch nas → verify pod+PVCs → seed from
  verified-live set via sqlite backup → restart → verify library in
  UI → split-brain connectivity checks → reconfigure in-app URLs →
  end-to-end download → flip (switch router) → verify → retire
  (`disabledServices` += lidarr, switch nas, old port dead).
- Rollback: revert Caddy flip, scale StatefulSet to 0, re-enable
  container service. POOL data never moved, only copied.

## Left to the builder

- Confirm Lidarr's live state dir layout on nas before seeding
  (`ls /mnt/POOL/starr/lidarr/` — do NOT assume top level like
  Sonarr's runbook did; find the live `.db` first).
- Confirm download test file lands under Music (proves the RW path
  for this app's root folders).

## Builder self-check (no subagent tool)

- No new PV, no new secrets, no new mechanisms — pure repetition.
- Seed-from-verified-live-set is step 1 of seeding, not an
  afterthought (Sonarr lesson encoded in ordering).

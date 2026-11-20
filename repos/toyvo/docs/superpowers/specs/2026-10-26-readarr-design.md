# Readarr migration to k3s — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: same template as Radarr/Lidarr/Sonarr (smallest library, lowest risk)

## Intent / why

Fifth starr move, smallest library. Structurally identical to the
others: single SQLite config dir, no VPN, API relationships to
already-moved Prowlarr and still-container qBittorrent. Leaves Bazarr
(the odd one — reads *from* the other apps' libraries) for last.

## Goals

- Readarr in k3s (linuxserver image pinned
  `lscr.io/linuxserver/readarr:develop-0.4.18.2805-ls157`, PUID/PGID
  352 per nixpkgs `ids.uids/gids.readarr`) as a StatefulSet pinned
  to nas, sqlite on local-path (never NFS).
- Media via the existing `pool-media-rw` PVC pattern (new
  `readarr-media` PVC 100Gi RWX nfs-pool, same shared export).
- Data seeded from the verified-live set: locate the live `.db`
  first with sudo (the state dir itself is permission-gated;
  presumed XDG `.config/Readarr/`), `.backup` + integrity check +
  count before trusting it, `chown` to 352. NOTE: the container
  runs nixpkgs' readarr service, not a linuxserver image, so there
  is no container tag to match — DB schema risk is low (SQLite
  `.backup` restore is the same mechanism as the others) but verify
  counts in the UI before flip.
- In-app reconfiguration (user, in Readarr UI): indexer →
  `https://prowlarr.diekvoss.net`, download client →
  `http://10.200.0.2:4080` (API key unchanged, seeded with config).
- qBittorrent Default Save Path is already `/mnt/Downloads`
  (set during Radarr); Readarr inherits the same visible geometry,
  no Remote Path Mappings.
- Ingress `readarr.diekvoss.net` + Caddy `upstreams` flip
  (forward-auth already off starr-wide).
- Old container service disabled via `disabledServices` after a
  successful in-app reconfiguration + UI verification; old port
  confirmed dead.

## Non-goals

- No new PV (reuse `pool-media-rw` with a per-app PVC — PVs bind
  1:1, established pattern).
- No secret work (key rides with the seeded config); no other moves.

## Anti-goals

- Don't restart or otherwise touch the container Readarr until k8s
  is verified (its live DB is the seed source).
- Don't run two Readarrs against the library (retire promptly
  after verify); don't touch `/mnt/POOL/Public` ACLs (pod runs as
  existing UID).
- Download test deferred (same as Lidarr/Radarr — indexers stale,
  rebuild later; Sonarr proved the import path and each migration
  verifies a pod write).

## Constraints

- Local-path volume node-pinned to nas; RW media PVC on `nfs-pool`.
- Seed source = live set (verify with sudo `ls` first; backup +
  integrity + count).
- Split-brain URLs identical in shape to the others (public
  prowlarr, direct qbittorrent); verify from the pod before flip.
- Manifest propagation lag: allow minutes after switch; delete
  stale pods rather than waiting (Radarr lesson).
- Verify image tags against the hub API before writing manifests
  (Radarr lesson — transposed version).

## Approaches considered

- Same template (picked): fifth repetition, no new mechanisms.
- Anything else (rejected): nothing about Readarr differs
  structurally from the others.

## Decided (what the builder implements)

- `modules/nixos/k3s-starr.nix`: add `readarr` block mirroring
  radarr (port 8787, image pinned above, PUID/PGID 352,
  `readarr-media` PVC 100Gi RWX nfs-pool, `/mnt` mount,
  nodeAffinity nas, 5Gi config claimTemplate).
- `homelab.nix` `starr.services.readarr.upstreams` set (dark until
  router switch).
- Runbook (user executes): switch nas → verify pod+PVCs → seed from
  verified-live set via sqlite backup → restart → verify book
  count in UI → split-brain connectivity checks → reconfigure
  in-app URLs → pod write test (`touch /mnt/.write-test`) → flip
  (switch router) → verify incl. failover → retire
  (`disabledServices` += readarr, switch nas, old port dead).
- Rollback: revert Caddy flip, scale StatefulSet to 0, re-enable
  container service. POOL data never moved, only copied.

## Left to the builder

- Confirm Readarr's live state dir layout on nas before seeding
  (sudo-gated; presumed `.config/Readarr/`).
- Confirm download client re-test clears (validates the shared
  `/mnt/Downloads` geometry for a fourth app).

## Verification bar (agreed 2026-10-26)

Full end-to-end downloads are deferred across the *arr migrations
(indexers stale; rebuild later). Each migration proves instead:
(1) seeded library matches in the k8s UI, (2) split-brain API
reachability from the pod, (3) a real pod write to the library
path, (4) Caddy flip + failover, (5) old port quiet. Sonarr already
proved the full download loop once; that stands as the template's
import proof.

## Builder self-check (no subagent tool)

- No new PV, no new secrets, no new mechanisms — pure repetition.
- Image tag verified against hub listing (develop-branch pin;
  no stable release exists for readarr).
- Download test deferred per standing decision.

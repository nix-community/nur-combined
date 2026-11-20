# Prowlarr migration to k3s — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: StatefulSet + local-path, hand-seeded data, Caddy upstreams flip

## Intent / why

Migrate Prowlarr (indexer hub, 10.200.0.2:9696) as the first stateful
service: smallest footprint in the starr stack (one SQLite config dir,
no media writes, no VPN), API-only relationships that survive the
split-brain period. Establishes the per-service migration template
Sonarr/Radarr/Lidarr/Readarr/Bazarr will reuse.

## Goals

- Prowlarr runs in k3s (linuxserver image, pinned tag, PUID/PGID 351
  to match existing file ownership/ACLs) as a StatefulSet pinned to
  nas, sqlite on local-path (never NFS — same rule as Postgres).
- Data seeded by hand: copy `/mnt/POOL/starr/prowlarr` into the
  provisioned local-path volume dir on nas, restart pod.
- Ingress `prowlarr.diekvoss.net` (class traefik); router Caddy vhost
  gains `upstreams = [ "10.1.0.3:30080", "10.1.0.12:30080" ]`
  (same flip as homepage), forward_auth unchanged.
- Old container service disabled after cutover verified (config + API
  key migrate with the data dir; no new Secret needed).
- Smoke-proven: UI 200 with auth gate, API key works (homepage widget
  or direct `/api/v1/...` call), a *arr still in the container can
  reach it (split-brain API call works both directions).

## Non-goals

- No other *arr moves; no media PV needed (Prowlarr never touches
  `/mnt` — verified in the container module: no media bind for it).
- No init-copy automation (explicit user choice; by hand this time).
- No secret creation (API key rides inside the seeded config).

## Anti-goals

- Don't put sqlite on NFS (locking risk; stated in storage design).
- Don't change PUID away from 351 (ownership continuity with the
  existing state dir and POOL ACLs).
- Don't break the container-side *arrs mid-migration: keep the old
  service running until the k8s instance is verified, then disable.
- No public exposure change (same host, same auth gate, same Caddy).

## Constraints

- Local-path volume is node-pinned: StatefulSet gets
  `nodeAffinity: nas` (data lives on nas NVMe only).
- Seeding is manual: PVC binds → volume dir appears under
  `/var/lib/rancher/k3s/storage/` on nas → rsync old dir in →
  rollout restart. Pod crashloops-or-fresh-starts on empty dir are
  harmless; overwrite-then-restart is the procedure.
- Caddy generator already supports `upstreams` (proven by homepage).
- Homepage widget already points at the public hostname, so it
  follows the flip with no change.

## Approaches considered

- linuxserver image with PUID/PGID (picked): the standard *arr
  container shape, UID continuity with existing files, tag-pinnable.
- NixOS closure-in-container (rejected): heavier, fights the k8s
  image-pull model, no benefit for a first migration.
- Dynamic provisioner or NFS for the sqlite (rejected): NFS locking
  risk; dynamic provisioning deliberately deferred.

## Decided (what the builder implements)

- New module `modules/nixos/k3s-starr.nix` (one file for the whole
  future suite; Prowlarr first, others as follow-ups) with
  `options.nixcfg.k3sStarr.prowlarr.enable`, generating from nas only:
  StatefulSet `prowlarr` (replicas 1, image
  `lscr.io/linuxserver/prowlarr:<pinned tag>`, env
  PUID=351/PGID=351 + TZ, containerPort 9696, volumeClaimTemplate
  5Gi default/local-path class), Service ClusterIP :9696, Ingress
  class traefik host `prowlarr.diekvoss.net` → service.
- `homelab.nix` `starr.services.prowlarr.upstreams` set (Caddy flip,
  separate commit from the manifests — dark-deploy first).
- nas config: `nixcfg.k3sStarr.prowlarr.enable = true`.
- Runbook (user executes): switch nas → verify pod + PV →
  `rsync -a /mnt/POOL/starr/prowlarr/ <volume-dir>/` on nas →
  rollout restart → verify UI/API → flip Caddy (switch router) →
  verify → disable container prowlarr service.
- Rollback: revert Caddy flip (traffic back to container), scale
  StatefulSet to 0. Data dir on POOL untouched (copy, not move).

## Left to the builder

- Exact linuxserver/prowlarr tag pin (latest stable at build time;
  record it).
- Whether the container needs any of the NixOS module's extra env
  (check `services.prowlarr` defaults for required settings; usually
  none beyond the port).
- Confirm port 9696 inside the image (linuxserver default matches).

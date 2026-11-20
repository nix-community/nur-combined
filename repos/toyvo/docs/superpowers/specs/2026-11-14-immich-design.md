# Immich migration to k3s — Short Design

Date: 2026-11-14
Status: approved 2026-11-14 (approach A confirmed; downtime anytime; user populates Proton Pass)
Approach picked: Full stack in k3s (server + ML + Postgres + Valkey), version-pinned to v3.3.6, hand-seeded, Traefik Ingress flip

## Intent / why

Move Immich off its NixOS container (`containers.immich`, `10.200.0.12:2283`,
state in `/mnt/POOL/immich` with `library/`, `postgresql/`, `cache/`) into k3s
on the nas. This is the largest stateful migration after the *arrs + Home
Assistant: a 4-service stack (server + machine-learning + Postgres +
Valkey/Redis) with a large photo library and all metadata (albums, faces,
shares, API keys, OAuth) in Postgres. User requirement: every byte carries
over; downtime during cutover is acceptable.

## Goals

- Immich runs in k3s as a pinned stack in its own namespace (or default-ns,
  builder picks to match repo convention):
  - `immich-server` `ghcr.io/immich-app/immich-server:v3.3.6` (matches
    nixpkgs `pkgs.immich` 3.3.6 — zero version migration).
  - `immich-machine-learning` `ghcr.io/immich-app/immich-machine-learning:v3.3.6`.
  - Postgres `ghcr.io/immich-app/postgres:<tag matching 3.3.6 release>`
    (vectorchord-enabled; hub/ghcr-verified at build time), on local-path
    (never NFS — same rule as sqlite/Postgres everywhere).
  - Valkey `valkey/valkey:8-alpine` (or upstream-pinned redis image),
    cache-only.
  - All pinned to nas via `nodeAffinity` (state locality + ML on nas CPU).
- Data seeded from the verified-live container set:
  - Postgres via `pg_dumpall` from the live container DB (taken while the
    container is stopped or read-quiesced), restored into the k8s Postgres.
    Integrity-checked (table counts, `faces`, `albums`, `assets` non-empty).
  - Library (`/mnt/POOL/immich/library`) served from a new NFS RW PV
    (same `nfs-pool` pattern as the *arr media PVs). No re-upload.
  - ML cache/models (`/mnt/POOL/immich/cache`) seeded by rsync into a
    local-path volume so models don't redownload (several GB).
  - DB-riding config (users, API keys, Authentik OAuth client/secret,
    storage template) carries over with the dump — no reconfiguration.
- New secret contract `k8s/immich/secretspec.toml` for `DB_PASSWORD`
  (32-char generated; loaded into Proton Pass first, then
  `secretspec -p kube` into the `immich-db` Secret). Homepage widget key
  (`HOMEPAGE_VAR_IMMICH_API_KEY`) already exists — unchanged.
- Ingress `immich.diekvoss.net` (class traefik) + `homelab.nix`
  `immich.services.immich.upstreams = [ "10.1.0.3:30080", "10.1.0.12:30080" ]`
  flip. `forwardAuthGate = false` UNCHANGED (Immich does native OIDC against
  Authentik, like forgejo/*arr API clients).
- Old container retired via `nixcfg.containers.immich.enable = false` after
  verification; old port `10.200.0.12:2283` confirmed dead. POOL state dirs
  remain on disk as backups (never deleted in this plan).

## Non-goals

- No version upgrade (3.3.6 → 3.3.6; upgrades are a separate deliberate step
  after k8s is stable).
- No storage-template or library-path reorganization.
- No Authentik provider changes (redirect URI `https://immich.diekvoss.net`
  unchanged; client credentials ride with the DB dump).
- No ML hardware acceleration work (CPU on nas; GPU passthrough out of scope).

## Anti-goals

- Don't run two Immich servers against the same Postgres or the same
  library (split-brain writes + job-queue races). Cutover is
  stop-old → seed → verify-new, not parallel-run. Downtime accepted.
- Don't put Postgres or Valkey data on NFS (locking/corruption risk).
- Don't bake `DB_PASSWORD` or any secret into the Nix store (SecretSpec
  path only, same alias-invocation discipline as homepage/qbittorrent).
- Don't hand-edit the live container during migration (its DB dump is the
  seed source; keep it running until dump day, then stop it).

## Constraints

- Node-pinned to nas (Postgres local-path + library NFS export both live
  on nas); local-path claims: Postgres ~10Gi (builder measures `du` first),
  server config small, ML cache ~10Gi.
- Library needs a new NFS export (`/mnt/POOL/immich/library` or the parent
  `/mnt/POOL/immich`, `10.1.0.0/24(rw,...)`) + one RW PV per existing
  convention (PVs bind 1:1 — one PV for this migration).
- Upload path mapping: NixOS uses `/var/lib/immich`, upstream docker uses
  `/usr/src/app/upload`. The k8s server Deployment must mount the library
  PVC at the upstream path and set `IMMICH_MEDIA_LOCATION` accordingly —
  builder confirms at build time against the pinned image docs.
- Manifest propagation lag: allow minutes after switch; delete stale pods
  to recycle (established lesson).
- Image tags hub/ghcr-verified (established lesson from *arrs).
- qBittorrent downloads-broken work is independent; no coupling.

## Approaches considered

- Full stack in k3s, version-pinned, hand-seeded (picked): self-contained,
  one cutover, one rollback (flip back + re-enable container). Matches
  upstream compose shape and the repo's local-path-DB + NFS-media pattern.
- Thin move: server + ML in k3s, DB stays in the container (rejected after
  discussion): smaller first diff but splits state across two systems,
  needs pod→`10.200.0.12` networking + socket-auth rework, and forces a
  second DB-move cutover later to ever retire the container.
- Single all-in-one image a la linuxserver (rejected): doesn't remove the
  hard part (still needs external vectorchord Postgres), weakest
  version-parity story vs today's NixOS 3.3.6 build.

## Decided (what the builder implements)

- New module `modules/nixos/k3s-immich.nix` (separate file, mirroring
  `k3s-homeassistant.nix` — Immich is not starr): Postgres StatefulSet
  (local-path claimTemplate) + Valkey (emptyDir or 1Gi local-path, builder
  picks, cache-only) + server Deployment/StatefulSet + ML Deployment, each
  with Service ClusterIP, plus one Ingress `immich.diekvoss.net` using the
  shared `k3s-traefik-middlewares.nix` helper with
  `homelab.immich.services.immich` flags.
- `modules/nixos/k3s-storage.nix`: one new RW PV for the Immich library
  (same `nfs-pool` class, `Retain`, `vers=4.2`).
- `configurations/nixos/nas/configuration.nix`: `nixcfg.k3sStorage` export
  add for the Immich path + `nixcfg.k3sImmich.enable = true;`.
- `homelab.nix`: add `upstreams` to `immich.services.immich` (dark until
  router switch); widget block unchanged.
- `k8s/immich/secretspec.toml`: new contract for `DB_PASSWORD`
  (alias-invocation discipline, `refs.kube` pinned, verified with
  `kubectl get secret immich-db -o jsonpath`). User populates the value
  in Proton Pass (approved 2026-11-14); builder hands over the generated
  value + exact secretspec commands.
- Runbook (user executes, downtime window anytime — approved 2026-11-14): measure sizes → `pg_dumpall`
  from live container → switch nas (manifests deploy dark) → create
  DB + restore + integrity check → rsync library (already on POOL; verify
  mount) + rsync ML cache → rollout restart server/ML → verify login,
  album/photo counts, faces, shares, OAuth via Authentik, upload-one-photo
  test → flip (switch router) → verify incl. failover (stop k3s on nas,
  expect 200 via macmini path only for stateless — stateful stays on nas,
  so failover means Traefik re-route, not reschedule) → retire container
  (`enable = false`, switch nas, old port dead).
- Rollback: revert homelab flip, re-enable container, server points back
  at container DB/library (k8s scaled to 0). POOL backups untouched.

## Left to the builder

- Exact upstream Postgres image tag for the v3.3.6 release + Valkey tag
  (ghcr/hub-verified at build time).
- Measured sizes for PG data, library, ML cache → final claimTemplate/PV
  sizes (PVs are 4Ti-capacity thin refs in this repo; claims size to need).
- Confirm server upload-path mount + `IMMICH_MEDIA_LOCATION` / `DB_URL` /
  `REDIS_HOSTNAME` env wiring against the pinned image.
- Whether server and ML share one pod or are separate Deployments
  (upstream compose uses separate; recommend separate for independent
  restarts — builder picks, behavior identical).
- Valkey persistence: emptyDir vs 1Gi local-path (cache-only either way).

## Verification bar

(1) seeded k8s Postgres row counts match live (users, assets, albums,
faces non-empty), (2) UI login works through public URL with Authentik
OIDC, photo counts + albums + faces + shares match, (3) upload-one-photo
lands in the library and ML jobs complete, (4) Traefik flip + old port
dead, (5) homepage widget still green. No split-brain dual-write test —
forbidden by the anti-goals.

## Builder self-check (no subagent tool)

- Read as builder: no new mechanisms beyond the proven local-path-DB +
  NFS-media + secretspec + Ingress-flip template; the only Immich-specific
  steps are the 4-service wiring, the `pg_dumpall` seed, and the
  upload-path mount.
- Secrets never in store; DB never on NFS; no dual-run.
- Version parity (3.3.6 → 3.3.6) eliminates migration risk; upgrades later.

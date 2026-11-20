# Jellyfin migration to k3s — Short Design

Date: 2026-11-14
Status: approved 2026-11-14 (approach A+C confirmed; downtime anytime; transcode test title/client TBD at execution)
Approach picked: Official image (A) + hostPath DRI from day one (C), CPU fallback documented

## Intent / why

Move Jellyfin off its NixOS container (`containers.jellyfin`,
`10.200.0.6:8096`, state in `/mnt/POOL/jellyfin`, media read-only from
`/mnt/POOL/Public`) into k3s on the nas. Of the two remaining media
containers, Jellyfin is the easy one: a single stateful app with SQLite
state, no companion database, no cron, no second service. Nextcloud (PHP +
bundled Postgres + Collabora + cron sidecar + SMTP relay rework +
whole-POOL external storage + 9 apps) is deliberately deferred as a
separate, larger migration.

## Goals

- Jellyfin runs in k3s as a StatefulSet pinned to nas:
  - Official image `jellyfin/jellyfin` pinned to the exact version NixOS
    ships today (`pkgs.jellyfin` 12.4, src tag `v12.4` — hub-verified at
    build time; zero version migration).
  - SQLite/config seeded from the verified-live set (`/mnt/POOL/jellyfin`,
    394M) onto a standard 5Gi local-path claim.
  - Runs as UID/GID 359 (`ids.uids.jellyfin`) via `securityContext` — the
    Immich lesson applied up front: root gets squashed to `nobody` on the
    read-only NFS mount, and the media ACLs know 359.
  - Media read-only from NFS at `/mnt` (same mount path as the container).
    Dedicated RO PV (`pool-media-jellyfin-ro`, same share as
    `pool-public-ro`) since PVs bind 1:1 — builder confirms whether
    `pool-public-ro` is already claimed and picks accordingly.
  - **DRI from day one**: `hostPath` mount of the whole `/dev/dri`
    directory (same as the container's bind mount — immune to
    `card1`-vs-`card0` enumeration shifts) + `supplementalGroups`
    `[26, 303]` (host `video`/`render` GIDs, mirroring the container's
    `extraGroups`). No device plugin needed while pinned to nas.
    CPU transcoding is the documented fallback if DRI misbehaves.
- LDAP plugin (`jellyfin-plugin-ldap-authentication`) rides inside the
  seeded state dir — no Nix-store install machinery in k8s. Auth target
  stays the direct address `10.200.0.16:6636` already in the seeded
  `LDAP-Auth.xml` (never the `ldap.diekvoss.net` hostname, whose router
  mis-resolution is a separate open todos item).
- Homepage widget API key rides with the state (same as Immich).
- Ingress `jellyfin.diekvoss.net` (class traefik) + `homelab.nix`
  `jellyfin.services.jellyfin.upstreams` flip. `forwardAuthGate = false`
  UNCHANGED (LDAP native, like Immich's OIDC).
- Old container retired via `nixcfg.containers.jellyfin.enable = false`
  after verification; old port `10.200.0.6:8096` confirmed dead. POOL
  state dir remains on disk as backup (never deleted in this plan).

## Non-goals

- No version upgrade (12.4 → 12.4; upgrades are separate, deliberate).
- No DLNA/UPnP carry-over (multicast doesn't survive pod networking;
    user confirmed no DLNA use — builder verifies it's not depended upon
    in the seeded `system.xml`, nothing more).
- No LiveTV tuner work (no tuner hardware in the container config;
    builder confirms no tuner/DVR paths outside state+media).
- No device-plugin work (unnecessary while single-node pinned).

## Anti-goals

- Don't run two Jellyfins against one library/state (split-brain writes
    to sqlite + NFO sidecars). Cutover is stop-old → seed → verify-new.
    Downtime accepted (carried over from the Immich migration unless the
    user says otherwise at approval).
- Don't put sqlite state on NFS (locking/corruption risk).
- Don't bake any secret into the Nix store (no new secrets expected —
    API key + LDAP bind ride with the seeded state).
- Don't "fix" LDAP hostname resolution in this migration (separate todos
    item; direct-IP config carries over and works).

## Constraints

- Node-pinned to nas (state locality + DRI device locality); local-path
    state claim (5Gi for 394M actual), RO media PV.
- UID/GID 359 throughout (ownership continuity with POOL state + media
    ACLs, same as the container's `uid = mkForce` pin).
- Transcode temp lives in the state dir (local-path NVMe — fine).
- Manifests from nas ONLY (single-writer rule).
- Seed ONLY from the verified-live set; container untouched until dump day
    (no dump needed — sqlite files copy cold after stop).
- Manifest propagation lag + explicit pod deletion to recycle (standing lesson).
- Image tag hub-verified (standing lesson).

## Approaches considered

- Official image + 359 + DRI hostPath from day one (picked): closest to
    today's container (same image family, same device posture, same UID),
    version parity eliminates migration risk, DRI is six lines with
    graceful CPU fallback. User confirmed CPU-acceptable + DLNA-unused.
- linuxserver.io image + PUID/PGID (rejected): same shape, but a second
    image family for a one-app migration; version still has to match
    NixOS's 12.4 anyway. *arr consistency isn't worth it here.
- Official image CPU-only, DRI as later todo (rejected after discussion):
    the hostPath approach proved nearly free and low-risk, so deferring
    buys nothing — DRI ships day one with CPU fallback documented.

## Decided (what the builder implements)

- New module `modules/nixos/k3s-jellyfin.nix` (separate file, mirroring
    `k3s-immich.nix` — Jellyfin is not starr): StatefulSet (1 replica,
    nodeAffinity nas, pinned image, `runAsUser`/`runAsGroup` 359,
    `supplementalGroups` [26, 303], TZ, containerPort 8096, `/config`
    claimTemplate 5Gi, RO media PVC at `/mnt`, `hostPath` `/dev/dri` at
    `/dev/dri`), Service ClusterIP :8096, Ingress class traefik host
    `jellyfin.diekvoss.net` via the shared middleware helper with
    `homelab.jellyfin.services.jellyfin` flags.
- `modules/nixos/k3s-storage.nix`: one RO PV for the Jellyfin media
    mount (same `nfs-pool` class, `Retain`, `vers=4.2` + `ro`), unless
    the builder proves `pool-public-ro` is unclaimed and reusable
    (PVs bind 1:1 — default to a new one).
- `configurations/nixos/nas/configuration.nix`:
    `nixcfg.k3sJellyfin.enable = true;` (+ module import).
- `homelab.nix`: add `upstreams` to `jellyfin.services.jellyfin` (dark
    until switch; removes the edge route).
- Runbook (user executes, downtime window anytime — approved 2026-11-14): switch nas (dark: server at
    0 replicas OR full deploy with no traffic — builder picks, dark
    preferred) → verify infra → stop container → rsync state (394M) +
    `chown -R 359:359` the volume dir → scale to 1 → verify login
    (incl. an LDAP user), library/user counts, direct play + HW
    transcode test (dashboard must show hw; CPU transcode = acceptable
    fallback, not a failure) → flip (switch router... single nas switch
    under Traefik edge) → verify incl. public URL → retire container
    (`enable = false`, switch, old port dead).
- Rollback: flip back, re-enable container. POOL state + dump-era
    backups untouched.

## Left to the builder

- Hub-verify `jellyfin/jellyfin:12.4` exists (exact tag match to
    nixpkgs); if upstream tags differ, record the ruling + exact tag.
- Confirm `pool-public-ro` claim status (bound vs free) → new RO PV or reuse.
- Confirm no tuner/DVR/live-TV config in seeded state (grep `system.xml`
    + scheduled-tasks for tuner paths); confirm DLNA not depended upon.
- Whether server starts at 0 replicas dark (Immich pattern) or straight
    to 1 (no shared-DB hazard here — sqlite copies cold; builder picks,
    dark preferred for a clean seed window).
- Exact transcode-test media (a known HEVC file) + client to test with.

## Verification bar

(1) seeded state matches (libraries, users, incl. LDAP login green),
(2) direct play works, HW transcode confirmed on dashboard (CPU fallback
accepted only if DRI proves awkward — must be an explicit, recorded call),
(3) Traefik flip + old port dead, (4) homepage widget still green.
No split-brain dual-run — forbidden by the anti-goals.

## Builder self-check (no subagent tool)

- Read as builder: no new mechanisms beyond the proven local-path-state
    + NFS-media + Ingress-flip template; the only Jellyfin-specific steps
    are the 359/DRI securityContext, the RO media PV question, and the
    LDAP plugin riding in state.
- No secrets in store; no DB on NFS; no dual-run.
- Version parity (12.4 → 12.4) eliminates migration risk.

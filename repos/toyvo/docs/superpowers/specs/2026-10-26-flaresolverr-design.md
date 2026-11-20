# FlareSolverr migration to k3s — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: same template minus storage (stateless — no PVC, no PV, no seed)

## Intent / why

Last migratable starr service. FlareSolverr is Prowlarr's
Cloudflare-solving proxy: stateless, no DB, no library, nothing to
seed. Everything it serves is already in k3s. qBittorrent (VPN
netns) stays containerized.

## Goals

- FlareSolverr in k3s (official image pinned
  `flaresolverr/flaresolverr:v3.5.2`, hub-verified 2026-10-26) as a
  StatefulSet pinned to nas (template consistency; no storage
  claims at all) — or a bare Deployment. Builder picks
  StatefulSet for one-line diff consistency with the template.
- No PVC, no PV, no seed. No PUID/PGID (not a linuxserver image).
- Ingress `flaresolverr.diekvoss.net` + Caddy `upstreams` flip
  (forward-auth off; homepage widget needs an HTTP(S) URL, same as
  the other services).
- In-app reconfiguration (user, in Prowlarr UI): FlareSolverr host
  → `http://flaresolverr:8191` (cluster-internal DNS, no Caddy
  round-trip). Current value is the container address and keeps
  working until repointed.
- Old container service disabled via `disabledServices` after
  Prowlarr's FlareSolverr host test goes green; old port confirmed
  dead.

## Non-goals

- No storage objects of any kind. No secret work. No other moves.

## Anti-goals

- Don't restart or otherwise touch the container FlareSolverr
  until k8s is verified (Prowlarr depends on one of the two being
  up at all times).
- Download test not applicable.

## Constraints

- Node-pinned to nas (affinity; template consistency).
- Port 8191 (containerPort + Service, matches current).
- Manifest propagation lag: allow minutes after switch; delete
  stale pods rather than waiting.
- Image tag already verified against hub API (v3.5.2).

## Approaches considered

- StatefulSet without volumeClaims (picked): keeps the
  `k3s-starr.nix` blocks structurally identical; the only
  difference is empty `volumes`/`volumeClaimTemplates`.
- Bare Deployment (rejected): marginally cleaner, but breaks the
  visual template for zero runtime benefit.

## Decided (what the builder implements)

- `modules/nixos/k3s-starr.nix`: add `flaresolverr` block
  mirroring readarr minus storage (port 8191, image pinned above,
  TZ only, nodeAffinity nas, no `/config`, no `/mnt`, no PVC/PV).
- `homelab.nix` `starr.services.flaresolverr.upstreams` set (dark
  until router switch).
- Runbook (user executes): switch nas → verify pod Running on
  nas → in Prowlarr UI repoint FlareSolverr host to
  `http://flaresolverr:8191` + test → flip (switch router) →
  verify incl. failover → retire (`disabledServices` +=
  flaresolverr, switch nas, old port dead).
- Rollback: revert Caddy flip, repoint Prowlarr host back to
  container address, scale StatefulSet to 0, re-enable container
  service.

## Left to the builder

- Nothing structural. Confirm Prowlarr's FlareSolverr host test
  passes against the cluster-internal address.

## Verification bar (agreed 2026-10-26)

(1) pod Running on nas, (2) Prowlarr FlareSolverr host test green
against `http://flaresolverr:8191`, (3) Caddy flip + failover,
(4) old port quiet. No seed proof (nothing to seed), no download
test (not applicable).

## Builder self-check (no subagent tool)

- No PV/PVC — stateless. No PUID/PGID — not linuxserver.
- Image tag verified against hub listing before writing manifests.

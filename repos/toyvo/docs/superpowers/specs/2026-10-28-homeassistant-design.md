# Home Assistant migration to k3s — Short Design

Date: 2026-10-26 (executed 2026-10-28)
Status: proposed, awaiting approval
Approach picked: *arr template minus media (no /mnt need), exact-version image,
adapted configuration.yaml

## Intent / why

Home Assistant is the last stateful service in a NixOS container
(`containers.hass`, 10.200.0.8:8123). Moving it to k3s leaves only
qBittorrent containerized (deliberately, VPN netns). HA is
structurally simple for k8s: no local hardware (no Z-Wave/Zigbee/
Bluetooth/mqtt — all integrations are cloud-polling or public-URL),
tiny sqlite DB (6.8 MB), empty custom_components, and an exact image
match exists so there is zero version-migration risk.

## Goals

- Home Assistant in k3s (`homeassistant/home-assistant:2026.5.4`,
  hub-verified — byte-identical version to the container's nixpkgs
  2026.5.4, so no DB migration, no breaking-change review) as a
  StatefulSet pinned to nas, sqlite on local-path (never NFS).
- Config seeded from the verified-live set: `.storage/*`,
  `.HA_VERSION`, blueprints, `.cloud`, `nest/`, `tts/`,
  `configuration.yaml` (adapted — see below), DB via sqlite
  `.backup` + integrity check. State dir is 46 MB total.
- `configuration.yaml` = the container's generated file verbatim
  (extracted via nix eval) PLUS `10.42.0.0/16` in
  `trusted_proxies` (Traefik pod IPs; Caddy's router IP already
  there). Without this, HA 400s every request behind Traefik.
- Ingress `home-assistant.diekvoss.net` + Caddy `upstreams` flip.
  forward-auth gate UNCHANGED (default on — matches current behavior;
  mobile app + webhooks keep working through the same public flow).
- Homepage widget URL → `https://home-assistant.diekvoss.net` at
  flip (API key unchanged, seeded with `.storage/auth*`).
- Old container disabled via its `enable` flag after verification;
  old port confirmed dead.

## Non-goals

- No media PVC/PV (`/mnt` unused by HA — no library paths, no
  downloads; tts/backups live in `/config`, which is local-path).
- No version upgrade (2026.5.4 → 2026.5.4; upgrades are a separate,
  deliberate decision).
- No secret work (auth rides with seeded `.storage`).

## Anti-goals

- Don't restart or otherwise touch the container HA until k8s is
  verified (its live DB is the seed source).
- Don't run two HAs against the same DB (retire promptly after
  verify); SQLite on local-path only.
- Don't "fix" the mobile app auth flow — behavior must be identical
  pre/post flip.

## Constraints

- Local-path volume node-pinned to nas; 5Gi claimTemplate (46M actual).
- Seed source = live state (verify with `ls` first; DB via backup +
  integrity + count of entities).
- Run as root (image default; no PUID/PGID concept). Ownership drift
  acknowledged: new files will be root-owned; rollback requires
  `chown -R hass` on the state dir. Documented, accepted.
- Manifest propagation lag: allow minutes after switch; delete stale
  pods rather than waiting.
- Image tag already verified against hub API (2026.5.4 exact match).

## Approaches considered

- Same StatefulSet template minus media (picked): proven shape,
  minus the parts HA doesn't need.
- Keep HA containerized (rejected: user direction is zero NixOS
  containers except VPN-bound qBittorrent).

## Decided (what the builder implements)

- New `modules/nixos/k3s-homeassistant.nix` (separate module, mirroring
  k3s-homepage.nix precedent — HA is not starr): StatefulSet
  (1 replica, nodeAffinity nas, image pinned, TZ,
  containerPort 8123, `/config` claimTemplate 5Gi, NO media mount),
  Service ClusterIP :8123, Ingress class traefik host
  `home-assistant.diekvoss.net`.
- nas config: `nixcfg.k3sHomeassistant.enable = true;`.
- `homelab.nix` `home-assistant.services.home-assistant.upstreams`
  set (dark until router switch) + widget URL flip at cutover.
- Runbook (user executes): switch nas → verify pod →
  seed from verified-live set (static tree + .backup DB + adapted
  configuration.yaml) → restart → verify login, entity counts,
  integrations green (omada/nest/met via their public URLs) →
  split-brain checks (public URLs reachable from pod) → flip
  (switch router) → verify incl. failover → retire (container
  `enable = false`, switch nas, old port dead).
- Rollback: revert Caddy flip, re-enable container, `chown -R hass`
  the state dir if k8s wrote root-owned files.

## Left to the builder

- Confirm recorder is default-sqlite (no external DB configured).
- Confirm no `trusted_proxies` surprises in `.storage/http`.

## Verification bar (agreed 2026-10-26, adapted)

(1) seeded UI matches (login works, entities present, no unavailable
storm), (2) cloud integrations load with no errors, (3) Caddy flip +
failover, (4) old port quiet. No download test (not applicable);
no split-brain API checks (no local API peers — integrations are
cloud/public-URL).

## Builder self-check (no subagent tool)

- No new PV, no new secrets, no new mechanisms — minus media.
- Image tag verified; version parity eliminates migration risk.
- configuration.yaml adaptation (trusted_proxies) is the single
  HA-specific step; everything else is the proven template.

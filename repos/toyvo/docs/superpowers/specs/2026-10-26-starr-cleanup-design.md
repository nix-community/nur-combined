# Starr container cleanup — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: delete retired service definitions, keep qBittorrent stack intact

## Intent / why

All seven container services (6 *arrs + flaresolverr) are retired to
k3s via `disabledServices`. The container now exists solely for
qBittorrent (VPN netns). The force-disable machinery, dead service
blocks, ports, UID pins, and bind mounts are dead code — remove
them so the module says what the container actually is.

## Goals

- `modules/nixos/containers/starr.nix` describes a qBittorrent-only
  container: remove the seven retired `services.*` blocks, their
  `ports.*` options, their state-dir bindMounts, their UID pins +
  groups, and the `disabledServices` option + `mkForce` machinery.
- nas config: remove the `disabledServices` list; refresh stale
  comments.
- homelab.nix: refresh `(plan step: flip)` upstreams comments to
  steady state (entries themselves stay — Caddy + widgets serve
  k8s through them).

## Non-goals

- No POOL state dir deletion (backups + rollback path stay on
  disk, untouched).
- No homelab service entry removal. No qBittorrent changes (it
  works; the declarative save path just landed).
- No NAT masquerade removal (generic container egress; zero gain,
  nonzero risk).

## Anti-goals

- Don't touch the VPN namespace, WireGuard, port-forward, or
  socket proxy wiring.
- Don't break the qBittorrent WebUI path (container IP:4080 via
  Caddy) — the *arrs depend on it.
- Don't orphan the UIDs: pins go away with the services, but
  nothing else references them (verified at build time by eval).

## Constraints

- qBittorrent must survive byte-identical in behavior: same ports,
  same serverConfig merge, same bind mounts (`/mnt`, protonvpn
  key, `/var/lib/qBittorrent`), same units.
- Validation is eval + nas toplevel build; the switch itself is
  manual (user), with post-switch checks.

## Approaches considered

- Full deletion of dead code (picked): the module is small (413
  lines); deletions are greppable and the build proves coherence.
- Leave `disabledServices` in place (rejected): it exists only to
  retire services, and there is nothing left to retire.

## Decided (what the builder implements)

- starr.nix edits per the Goals list; `services` becomes a plain
  attrset with only `qbittorrent`.
- nas config: drop `disabledServices`; update the starr section
  comments.
- homelab.nix: reword the seven `upstreams` comments.
- Runbook (user executes): switch nas → verify qbit WebUI 200,
  no listeners on retired ports, container units show only
  qbittorrent + support services → done.
- Rollback: re-add from history; state dirs untouched throughout.

## Left to the builder

- Nothing structural. Keep the diff deletion-only except
  comments.

## Verification bar

(1) eval + toplevel build green, (2) post-switch qbit WebUI 200,
(3) retired ports quiet, (4) no references to removed options
anywhere (`rg disabledServices` empty).

## Builder self-check (no subagent tool)

- Deletion-only. No behavior change to qBittorrent by
  construction (its blocks untouched).
- POOL state dirs explicitly out of scope.

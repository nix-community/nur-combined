# WireGuard → NetBird self-hosted — Short Design

Date: 2026-11-18
Status: draft (needs sign-off on control-plane home + IdP + oracle role)
Approach picked: self-hosted NetBird (management + signal + relay +
dashboard) on the LAN, Authentik as OIDC IdP, oracle joins k3s as AGENT
ONLY after the NetBird underlay is green.

## Current state (manual WireGuard, hub-spoke via router)

- Router `.1`: hub, `listenPort 51820` (public `toyvo.dev:51820`).
- Oracle `.2`: full LAN routes (10.1/10.200/10.100). Purpose: rclone
  backups to nas + game-server management + (future) k3s member.
- Pixel10a `.3` (phone): LAN access for mobile use.
- Keys: per-host sops (`wireguard-{router,oracle,pixel10a}-private-key`),
  hand-distributed public keys in configs. No rotation story, no
  central policy, every peer change = 2+ host switches.

## Goals

- NetBird control plane self-hosted (no NetBird Cloud account,
  no external dependencies beyond what we already run):
  `management`, `signal`, `relay` (coturn), `dashboard` — official
  `netbirdio/*` images, version-pinned at build time.
- Authentik as the OIDC IdP (already the house authority; users/groups
  already exist — no parallel user database). No circular dependency:
  Authentik stays LAN-reachable directly, never depends on NetBird.
- Migrate the 3 existing peers 1:1 first (same IPs/subnets if
  possible — 10.100.0.0/24 stays the overlay, zero client reconfigs
  beyond installing the agent).
- THEN oracle joins k3s as AGENT ONLY (no etcd — WAN latency makes
  etcd elections fragile; agents need only :6443, which tolerates it).
  Game servers stay latency-pinned via nodeAffinity regardless.
- Retire the manual configs only after every peer is green on NetBird
  (dual-run is safe: different interfaces/ips, no conflicts).

## Non-goals

- No fleet-wide enrollment day one (20 machines stay on direct LAN;
  NetBird is for the off-LAN members: oracle, pixel, + future).
- No exit-node / routed-networks reshaping (keep the current flat
  10.100.0.0/24 semantics; policy refinements later).
- No Authentik-behind-NetBird (Authentik must never depend on the
  overlay it authenticates).

## Risks

- Signal/coturn need PUBLIC UDP reachability (STUN hole-punch + TURN
  relay fallback). Home uplink behind CGNAT? If yes, everything
  hairpins through the relay — must be sized/placed accordingly
  (oracle has the public IP; relay placement matters).
- Authentik OIDC integration: NetBird management needs the IdP
  reachable at setup + enrollment time. Chicken-and-egg only if
  Authentik moves — it doesn't (k3s, LAN, stable).
- Oracle→home latency for k3s agent traffic (API + kubelet + pod
  overlay). Agents tolerate it; etcd would not (hence agent-only).
- Key migration: WireGuard keys do NOT transfer (different crypto) —
  enrollment is fresh per peer, old configs stay until cutover proven.

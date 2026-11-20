# Authentik migration to k3s — Short Design

Date: 2026-11-16
Status: draft (needs user sign-off on sequencing § + LDAP NodePort)
Approach picked: upstream images at nixpkgs parity, dark deploy against
the live host Postgres, flip the Traefik forwardAuth address in one
switch, then retire the three containers.

## Intent / why

Last NixOS container. Authentik (server .16 + worker .18 + redis .20) is
the cluster's identity authority — every gated app and Jellyfin's LDAP
depend on it. Migrate it with zero session/secret churn and an atomic,
instantly-revertible cutover.

## Goals

- Images at nixpkgs parity (ghcr-verified at build time):
  - `ghcr.io/goauthentik/server:2026.5.6` (nixpkgs authentik 2026.5.6)
  - `ghcr.io/goauthentik/ldap:2026.5.6` (outpost; verify tag exists —
    fall back to `ghcr.io/goauthentik/outpost-ldap` naming if the org
    moved it, record verbatim)
  - `redis:8.10.3` (nixpkgs redis 8.10.3)
- Shapes (one writer each, replicas 1, nodeAffinity nas):
  - Server Deployment, worker Deployment, beat Deployment (exact
    `ak server` / `ak worker` / `ak beat` command parity with NixOS).
  - LDAP outpost Deployment (same token, `AUTHENTIK_HOST` = in-cluster
    server URL) + TCP NodePort for LDAPS :6636 (Jellyfin flips to it).
  - Redis StatefulSet + local-path PVC (sessions/cache carried over;
    losable in theory, kept per the standing rule).
- Config translated 1:1 (env + file-mounted config.yml pattern):
  `AUTHENTIK_POSTGRESQL__*` → host Postgres 10.1.0.3:5432 (DB stays —
  no PG migration), `AUTHENTIK_REDIS__*` → in-cluster redis,
  `secret_key` + db password from secret files, bootstrap password
  carried (unused post-bootstrap, harmless).
- State: media + custom-templates + certs (POOL, small) → local-path
  PVCs, UIDs chown'd to image runtime (verified at Task 1; goauthentik
  images historically run as root — confirm, don't assume).
- Secrets (ALL carried over — rotating any of these logs out the
  world or breaks enrollment): `secret-key`, `db-password`,
  `ldap-token`, `bootstrap-password` via secretspec → k8s Secrets
  (user loads from sops/pass, kubectl-direct like office).
- Probes: server `/-/health/live/` + `/-/health/ready/` (real
  endpoints — no fake 200s); worker/beat/outpost: TCP or process
  checks as appropriate; generous initial delays (first boot runs
  migrations + blueprint application).
- Networking:
  - In-cluster: ClusterIP Services (server:9000; redis:6379).
  - Server UI/admin: NOT separately ingressed (admin lives behind the
    same gate as everything else — auth.diekvoss.net keeps working
    through the flipped forwardAuth with zero URL changes).
  - LDAP: NodePort on nas (TCP :6636) — Traefik can't do raw LDAPS
    without TCP route config; NodePort keeps it off the edge.

## Sequencing (the whole game)

The gate can't dual-run (two session authorities = split-brain
logins). Old and new coexist with OLD serving until one atomic flip:

1. Dark deploy: full k3s stack against live host PG + new redis, same
   secret key. Verify DIRECT (port-forward, bypassing the gate):
   admin login, version, users/groups/providers intact, outpost shows
   connected in the admin UI, LDAP bind works against the new outpost.
2. THE FLIP (one switch): Traefik `forwardAuth.address`
   (`k3s-edge.nix`, currently `http://10.200.0.16:9000/...`) → in-cluster
   `http://authentik:9000/...`. Verify IMMEDIATELY in incognito: gated
   app → authentik challenge → login → app loads. If red: revert the
   ONE line (old container untouched and still warm).
3. LDAP flip: Jellyfin LDAP host → nas NodePort (off-hours, one
   config change, test bind + login). Rollback = flip back.
4. Retire: all three containers `enable = false`, old IPs verified
   dead, POOL dirs retained.

## Non-goals

- No Postgres move (stays on host; k3s pod traffic SNATs to node IPs
  already covered by the 10.1.0.0/16 + 10.200.0.0/16 scram rules —
  verified at Task 2, pg_hba change only if proven needed).
- No OIDC client changes (all clients use the public auth.diekvoss.net
  URL, untouched by the backend move).
- No version upgrades, no blueprint changes, no provider reconfig.

## Risks

- The flip switch is the highest-blast-radius single switch in the
  project (every gated app). Mitigations: exhaustive dark verification
  first; old stack warm; revert is one line; execute attended with the
  incognito test ready BEFORE switching.
- Secret-key mismatch = silent session invalidation cluster-wide.
  Mitigation: byte-compare the secret (`diff` sops file vs k8s secret)
  before the flip, not after.
- LDAP cert: the outpost serves LDAPS with a server-managed cert —
  verify the chain from Jellyfin's perspective (LDAPS verify), not
  just a TCP connect.
- Jellyfin LDAP flip strands logins if wrong — do it off-hours with
  the old endpoint documented for instant revert.

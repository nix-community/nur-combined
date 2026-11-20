# Task 1 brief — pins + UIDs + secrets (2026-11-16)

Registry verifications (all 200):
- `ghcr.io/goauthentik/server:2026.5.6` (ghcr token flow) — image User `1000`
- `ghcr.io/goauthentik/ldap:2026.5.6` (same flow — the `goauthentik/ldap`
  repo name is correct, no `outpost-ldap` fallback needed) — image User `1000`
- `redis:8.10.3` (hub API) — image User `` (root, official default)

UID decision: run server/worker/beat/ldap as **362** (NixOS `ids.uids.authentik`
parity — POOL seeds are already 362-owned, zero chown, and the NixOS
systemd units prove the binaries run fine as non-root 362). Redis runs
as image-default root. Design doc § state updated accordingly at Task 2.

Secrets inventory (sops on nas → k8s Secrets, kubectl-direct like
office/monitoring; values never in docs):
- `authentik-secret-key` (MUST carry byte-identical — sessions + tokens)
- `authentik-db-password` (host PG role password, set via activation)
- `authentik-bootstrap-password` (post-bootstrap unused, carried anyway)
- `authentik-ldap-token` (outpost enrollment, carried — no re-enroll)

`k8s/authentik/secretspec.toml`: contract skeleton to be completed in
Task 2 alongside manifests.

Open design sign-offs needed before Task 2 build:
1. Dark-deploy + atomic forwardAuth flip sequencing (design § Sequencing) — agreed?
2. LDAP via TCP NodePort on nas (:6636) for Jellyfin (Traefik can't do raw
   LDAPS without TCP config) — agreed, or prefer another path?

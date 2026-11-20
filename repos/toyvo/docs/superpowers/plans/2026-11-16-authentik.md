# Authentik migration to k3s — Plan

Date: 2026-11-16
Design: `docs/superpowers/specs/2026-11-16-authentik-design.md`
(dark deploy against live host PG, atomic forwardAuth flip, retire)

## Task 1 — Pin + verify images, UIDs, secrets inventory (executor: agent)

- Registry-verify (expect 200): `ghcr.io/goauthentik/server:2026.5.6`
  (ghcr API, office precedent), `redis:8.10.3` (hub API), LDAP outpost
  image (confirm exact repo name — `goauthentik/ldap` vs
  `goauthentik/outpost-ldap` — and pin the 2026.5.6 tag verbatim).
- Record each image's runtime UID (registry config-blob flow, monitoring
  precedent). goauthentik historically runs as root — confirm.
- Secrets inventory (no values in docs, only names + sources):
  `authentik-secret-key`, `authentik-db-password`,
  `authentik-bootstrap-password`, `authentik-ldap-token` (all sops on
  nas today). Write `k8s/authentik/secretspec.toml` contract skeleton.
- Verify: versions + UIDs + image URLs recorded verbatim in
  `.superpowers/sdd/2026-11-16-authentik/task-1-brief.md`.

## Task 2 — Manifests dark (executor: agent)

- New `modules/nixos/k3s-authentik.nix` (registered in `default.nix`,
  NOT enabled anywhere): server + worker + beat Deployments, LDAP
  outpost Deployment + TCP NodePort (6636), redis StatefulSet +
  local-path PVC, media/templates/certs PVCs, ClusterIP Services,
  secrets wiring (file mounts for config.yml pattern), health probes.
- Env/config translated 1:1 from `containers/authentik.nix` (PG host
  10.1.0.3:5432, SSLMODE prefer, redis in-cluster, working dir
  /var/lib/authentik).
- Verify: `nix eval` renders all manifests, `nix build` nas toplevel
  green, NO cluster objects (module dark).

## Task 3 — Secrets live (executor: user + agent)

- User: read the four live values from sops on nas
  (`sudo cat /run/secrets/authentik-*`), `kubectl create secret generic`
  for each (office/monitoring precedent — pass-cli is headless-broken).
- Agent: byte-compare plan documented (sops file vs k8s secret —
  executed at Task 5 pre-flip, not now).
- Verify: Secrets exist with exactly the expected keys (`kubectl get
  secret ... -o jsonpath='{.data}'` shows key names only).

## Task 4 — State seed (executor: user + agent)

- User (containers still RUNNING — media/templates/certs are
  read-mostly, no DB to freeze since PG stays on host): copy
  `/mnt/POOL/authentik/{media,custom-templates}` (+ worker `certs`)
  and `/mnt/POOL/authentik-redis` to staging, `du -sh` for the record.
- Agent: enable module, switch (k3s stack up EMPTY against live PG +
  new redis — reads nothing yet, writes nothing yet).
- User: `chown -R <image-uid>` + move into PVC dirs, delete k3s pods
  to restart onto seeded state.
- Redis: copy or fresh (small; decide at seed time — sessions re-login
  either way since secret key is unchanged).
- Verify: pods green, media reachable (direct port-forward: admin UI
  shows custom logo if any; outpost status page).

## Task 5 — Dark verification (executor: agent + user, ATTENDED)

- Agent: port-forward to k3s server (bypass the gate entirely).
- User (browser via forward or curl): admin login works, version
  matches, users/groups/providers/applications all present, LDAP
  outpost shows connected in System → Outposts, test LDAPS bind
  against the new NodePort with a real user (expect success).
- Agent: byte-compare secret key (sops file vs k8s secret — `diff`
  must be EMPTY). Byte-compare db password likewise.
- Verify: ALL checks green. If ANY red: stop, fix, re-verify. The flip
  does NOT happen on a yellow board.

## Task 6 — THE FLIP + LDAP + retire (executor: agent + user, ATTENDED)

- Agent: flip Traefik `forwardAuth.address` in `k3s-edge.nix` to the
  in-cluster server (one line), switch nas.
- User (incognito, prepared BEFORE the switch): gated app URL →
  expect authentik challenge → login → app loads. Test 2–3 gated apps
  + one public URL (should stay public).
- If red: agent reverts the ONE line immediately, user re-tests
  (old container never stopped — still warm).
- If green: user flips Jellyfin LDAP to the new NodePort (off-hours),
  tests bind + login; agent retires all three containers
  (`enable = false`), verifies old IPs dead
  (`curl 10.200.0.16:9000` refuses, `:6636` refuses).
- Verify: gate green on new stack, LDAP green on new outpost, old
  world dark, POOL dirs retained.

## Rollback (any task through Task 6)

- Pre-flip: nothing to roll back (dark stack touches nothing live).
- Post-flip: revert the ONE forwardAuth line (one switch, ~2 min);
  old container still running until Task 6 closes it out.
- Post-retire: `enable = true` on the three containers + flip the
  address back; POOL state retained; k3s state retained.

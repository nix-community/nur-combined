# Task 2 brief — manifests dark (2026-11-18)

`modules/nixos/k3s-netbird.nix` written, registered in `default.nix`,
NOT enabled anywhere (validated via temporary enable + eval, then
reverted to dark — no cluster objects will be created).

13 manifests (verified by name in eval output):
- management Deployment (envsubst init + app; sqlite PVC 5Gi;
  TCP probes) + ConfigMap (management.json.tmpl) + ClusterIP :33073
  + public Ingress `netbird-mgmt.toyvo.dev` (forward-auth OFF —
  agents use setup keys, no browser session)
- signal Deployment (:80 plain HTTP, TCP probes) + ClusterIP +
  public Ingress `netbird-signal.toyvo.dev` (no gate, WSS via Traefik)
- relay Deployment (NB_* env, :33080 UDP) + UDP NodePort 33080
- dashboard Deployment (nginx :80, full AUTH_* OIDC env) + ClusterIP +
  LAN Ingress `netbird.diekvoss.net` (forward-auth ON — admin UI)
- Secrets wired via valueFrom (never in ConfigMap/store); template
  $VARS substituted at start by busybox:1.37.0 init (hub-verified).

Content spot-checks (eval): init image busybox:1.37.0, relay nodePort
33080/UDP, management args start with --port. wildcard-tls-toyvo-dev
exists in-cluster (5d old — traefik-cert-sync covers toyvo.dev).

Deliberate choices (in-module comments):
- Relay-only, no coturn (one less component; add only if P2P fails
  across NATs and relay hairpinning proves insufficient).
- SQLite, no extra Postgres (matches upstream small-deploy default).
- IdPManager `none` (no user/group sync — users materialize on first
  OIDC login; fine for 3 peers).
- Signal/management plain HTTP in-cluster (TLS terminates at Traefik).

User steps pending (Task 3/4, all manual):
- Cloudflare DNS: netbird-mgmt + netbird-signal + relay .toyvo.dev → home IP.
- Home-router UDP forward: <public>:33080 → nas:33080.
- Authentik OIDC app `netbird` (provider + app, redirect dashboardHost + /silent-callback).
- 5 secrets via kubectl-direct (2 generated fresh, 3 from Authentik).

`k8s/netbird/secretspec.toml`: full 5-key contract. Design + plan in
`docs/superpowers/{specs,plans}/` (gitignored). SDD task dir:
`.superpowers/sdd/netbird/` (this brief).

Next: Task 3 — user does the 4 manual steps above; agent verifies
Secrets exist, then Task 4 enables the module.

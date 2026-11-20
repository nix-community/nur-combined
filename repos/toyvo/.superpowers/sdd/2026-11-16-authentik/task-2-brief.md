# Task 2 brief — manifests dark (2026-11-16)

`modules/nixos/k3s-authentik.nix` written, registered in `default.nix`,
NOT enabled anywhere (validated via temporary enable + eval, then
reverted to dark — no cluster objects will be created).

12 manifests (verified by name in eval output):
- server/worker(+beat sidecar) Deployments (args server/worker/beat,
  runAsUser 362, workingDir /var/lib/authentik, full env set incl.
  PG host 10.1.0.3 + secret refs, health probes 120/180s)
- LDAP outpost Deployment (AUTHENTIK_HOST in-cluster + token ref,
  TCP probes) + NodePort 30636→6636
- redis StatefulSet (volumeClaimTemplate 5Gi, TCP probe, appendonly)
- 5 PVCs (data 5Gi, media 5Gi, templates 1Gi, certs 1Gi, redis via template)
- ClusterIP Services (authentik:9000, authentik-redis:6379)
- PVC sizes are estimates — Task 4 measures POOL dirs first.

Content spot-checks (eval): server args=[server], 9 env names,
ldap env=[AUTHENTIK_HOST AUTHENTIK_TOKEN], runAsUser=362 everywhere.

Deliberate divergences from the container (documented in-module):
- No config.yml files — pure env (NixOS used file:// refs; k8s uses
  valueFrom directly; equivalent).
- Bootstrap password carried in the Secret but unreferenced (single-use,
  already consumed; sops retains it for rebuilds).
- Worker/beat have no probes (no HTTP surface upstream; process exit
  restarts — same as NixOS Restart=on-failure).
- No nginx/LDAP gateway — outpost serves LDAPS directly (as it did in
  the container on :6636).

`k8s/authentik/secretspec.toml`: full 4-key contract (user populates at
Task 3). Design docs in `docs/superpowers/{specs,plans}/` (gitignored).

Next: Task 3 — user creates `authentik-secrets` from the four live sops
values; agent verifies key names. Then Task 4 seed (media/templates/
certs/redis from POOL; sizes adjust PVCs if needed).

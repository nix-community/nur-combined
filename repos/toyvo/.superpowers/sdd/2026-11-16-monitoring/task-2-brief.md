# Task 2 brief — manifests dark (2026-11-16)

`modules/nixos/k3s-monitoring.nix` written, registered in `default.nix`,
NOT enabled anywhere (validated via temporary enable + eval, then
reverted to dark — no cluster objects will be created).

18 manifests (verified by name in eval output):
- grafana: Deployment + PVC (5Gi) + ConfigMaps (ini/provisioning,
  dashboards via readFile) + ClusterIP Service + Ingress
  (forward-auth ON, `grafana.diekvoss.net`)
- prometheus: StatefulSet (volumeClaimTemplate 50Gi) + ConfigMap +
  ClusterIP + NodePort 30901, `--web.enable-admin-api` added for
  snapshot restores, probes 120/180s (cold TSDB load)
- loki: StatefulSet (50Gi) + ConfigMap + ClusterIP + NodePort 30902,
  nginx gateway dropped by design (NodePort is LAN-reachable)
- tempo: StatefulSet (20Gi) + ConfigMap + ClusterIP + NodePort
  30903/30904/30905, generator remote-write → `http://prometheus:9090`
- PVC sizes are estimates — Task 4 measures real state dirs first and
  adjusts before any pod starts.

Content spot-checks (eval): ingress annotation =
secure-headers,lan-only,forwardauth; pod securityContexts =
472 / 65534 / 10001 / 10001; tempo.yaml renders with cluster-local
prometheus URL.

`k8s/monitoring/secretspec.toml`: contract skeleton (user populates at
Task 3). Design docs in `docs/superpowers/{specs,plans}/` (gitignored,
working-copy only).

Next: Task 3 — user populates `grafana-admin-password` +
`grafana-secret-key` from Pass; agent creates the in-cluster Secrets.

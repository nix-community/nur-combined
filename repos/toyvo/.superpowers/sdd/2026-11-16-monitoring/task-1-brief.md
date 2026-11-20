# Task 1 brief — image pins + UIDs (2026-11-16)

All four upstream tags hub-verified 200 (anonymous API):

| Service | nixpkgs (live) | k3s image (pinned) | Runtime UID |
|---|---|---|---|
| Grafana | 13.3.0 | `grafana/grafana:13.3.0` | `472` |
| Prometheus | 3.16.0 | `prom/prometheus:v3.16.0` | `nobody` (65534) |
| Loki | 3.7.9 (`grafana-loki`; the `loki` attr is an unrelated 0.1.7 pkg) | `grafana/loki:3.7.9` | `10001` |
| Tempo | 3.1.1 | `grafana/tempo:3.1.1` | `10001:10001` |

UID method: registry token flow → amd64 manifest → config blob
(`curl -L` required; blobs 307 to CDN). Seeds must be chown'd to these
before pods start (jellyfin-359 precedent).

Secrets skeleton: `k8s/monitoring/secretspec.toml` — to be written in
Task 2 alongside manifests (contract: `grafana-admin-password`,
`grafana-secret-key`; user populates from Pass at Task 3).

Open design questions for user sign-off (spec § dual-write + networking):
1. Dual-write warmup (agents ship to old + new during Task 5) — agreed?
2. Agent ingest via NodePorts on nas (9090/3100/4317/4318/3200) vs
   Traefik edge routes for the HTTP ones — NodePort recommended
   (no Traefik TCP config, keeps scrape/push traffic off the edge).

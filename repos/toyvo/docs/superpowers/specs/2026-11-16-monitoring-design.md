# Monitoring stack migration to k3s — Short Design

Date: 2026-11-16
Status: draft (approach A below; needs user sign-off on dual-write + NodePort ingest)
Approach picked: full k3s-native stack (upstream images at nixpkgs parity),
dual-write warmup from Alloy agents, then flip reads, then retire container.

## Intent / why

Move the last infra-stateful container (`monitoring` at 10.200.0.4:
Grafana + Prometheus + Loki + Tempo as NixOS services) into k3s, same as
the app migrations. This is the palate cleanser before Authentik (the
final boss): same migration muscle, near-zero user-facing risk — a
monitoring gap annoys, it never locks anyone out.

## Goals

- All four services run in k3s pinned to nas, upstream images at exact
  nixpkgs parity (hub-verified at build time):
  - `grafana/grafana:13.3.0` (nixpkgs grafana 13.3.0)
  - `prom/prometheus:v3.16.0` (nixpkgs prometheus 3.16.0)
  - `grafana/loki:3.7.9` (nixpkgs grafana-loki 3.7.9 — NOT the nixpkgs
    `loki` attribute, which is an unrelated 0.1.7 package)
  - `grafana/tempo:3.1.1` (nixpkgs tempo 3.1.1)
- Shapes (one writer each, replicas 1, nodeAffinity nas):
  - Prometheus StatefulSet (TSDB needs stable identity) + local-path PVC.
  - Loki StatefulSet (single-binary, same flags as today:
    `auth_enabled=false`, inmemory ring, RF=1, filesystem
    chunks/index/compactor) + local-path PVC.
  - Tempo StatefulSet (local backend, same OTLP receivers + remote-write
    generator loop) + local-path PVC.
  - Grafana Deployment (sqlite) + local-path PVC. Official images run as
    their own UIDs (grafana 472, etc. — confirmed at build, seeds
    chown'd to match, same as the jellyfin-359 precedent).
- Config translated 1:1 from the NixOS service settings (no behavior
  change): prometheus `--web.enable-remote-write-receiver` + 30d
  retention; loki schema v13/tsdb + 336h retention; tempo local backend +
  block_retention 336h + metrics-generator remote-write loop;
  grafana `domain`/`root_url` + `$__file__` secrets + provisioned
  datasources/dashboards.
- Networking:
  - In-cluster: ClusterIP Services; Grafana datasources point at
    `http://prometheus:9090`, `http://loki:3100`, `http://tempo:3200`
    (replacing today's `localhost` URLs).
  - Agent ingest: NodePort Services on nas for Prometheus :9090,
    Loki :3100, Tempo OTLP :4317/:4318 (+ :3200 http). Agents re-point by
    flipping `homelab.monitoring.ip` + the port defaults in
    `modules/nixos/monitoring/default.nix` (single source of truth,
    all ~8 Alloy hosts follow on their next switch).
  - Loki nginx gateway (:3100 allowlist proxy) DROPPED — in k3s the
    NodePort + LAN-only posture covers it (agents are all LAN hosts;
    the allowlist semantics move to documentation, not a sidecar).
  - Grafana UI: plain Ingress `grafana.diekvoss.net` with forward-auth
    ON (same pattern as nextcloud/office) + TLS. The homelab edge route
    (10.200.0.4) is REMOVED at flip time — same host can't have two
    routers (office lesson, twice learned).
- Secrets: `grafana-admin-password` + `grafana-secret-key` via
  secretspec-managed Secrets (user loads from Pass, same as immich/office).
- Dashboards: 28K ConfigMap (3 JSONs) mounted at the provisioning path.
- Data: everything carries over (standing rule). Prometheus via
  snapshot API (clean TSDB handoff, no WAL replay surgery); Loki
  chunks+index copy; Tempo traces+wal copy; Grafana sqlite copy.
  Sizes + exact UIDs recorded at seed time.
- Cutover: DUAL-WRITE warmup (see below), then flip reads, then retire.
  Rollback = container `enable = true` + homelab IP flip back; POOL
  state retained until green + 1 week.

## Dual-write warmup (the key divergence from the app migrations)

Metrics/logs/traces are append-only streams, not databases — no
split-brain. Alloy supports multiple `remote_write`/`loki.write`/`otel`
exporters, so during warmup every agent ships to BOTH stacks:

1. Deploy k3s backends (empty), agents add the new endpoints alongside
   the old (one `homelab` + module-defaults change, agents switch
   over ~1 day).
2. Verify the new stack sees the same series/streams (spot-check +
   `count()` parity on a canary host).
3. Flip Grafana datasources to the new backends (reads move, writes
   already there — zero gap).
4. Flip UI Ingress, retire container, drop the old endpoints from
   agent configs.

Worst case (new stack misbehaves): reads flip back in one switch; the
old stack never stopped receiving.

## Non-goals

- No Alloy agent migration (agents stay host-native; only endpoint URLs
  change). No new dashboards, no retention changes, no alerting changes.
- No Loki `auth_enabled=true` or multi-tenancy (single-instance
  semantics preserved exactly).
- No Tempo backend change (local filesystem stays; object-store
  migration is a separate future project if ever).

## Risks

- Prometheus snapshot/restore across identical versions is routine, but
  verify `admin-api` is enabled for the snapshot endpoint (or copy the
  TSDB dir stopped — decided at build).
- Loki schema v13 + tsdb index copy must preserve the `index/` +
  `chunks/` + compactor dir layout exactly (bind-mount layout today =
  `/var/lib/loki/*`; keep identical mount paths in k3s to avoid config
  edits).
- The homelab edge-route removal + plain-Ingress addition must land in
  the SAME switch (no dual-router window on grafana.diekvoss.net).
- 8 agent hosts switch on their own cadence; dual-write tolerates
  stragglers, but the OLD container can't retire until the last agent
  drops it (track via Prometheus `up` / Loki stream labels).

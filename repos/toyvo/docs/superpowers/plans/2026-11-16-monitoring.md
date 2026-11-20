# Monitoring stack migration to k3s — Plan

Date: 2026-11-16
Design: `docs/superpowers/specs/2026-11-16-monitoring-design.md`
(approach A: upstream images at parity, dual-write warmup, flip reads, retire)

## Task 1 — Pin + verify images, record UIDs (executor: agent)

- Hub-verify (anonymous API, expect 200): `grafana/grafana:13.3.0`,
  `prom/prometheus:v3.16.0`, `grafana/loki:3.7.9`,
  `grafana/tempo:3.1.1`. Any 404 → stop, pick the nearest matching tag
  and re-verify (no drift from nixpkgs behavior).
- Record each image's runtime UID/GID (`docker inspect` equivalent via
  image config API or `crane config`) for seed chown + securityContext.
- Drop: `k8s/monitoring/secretspec.toml` skeleton (contract only —
  user populates from Pass at Task 3).
- Verify: eval of the (empty) module skeleton passes; versions + UIDs
  recorded verbatim in `.superpowers/sdd/2026-11-16-monitoring/task-1-brief.md`.

## Task 2 — Manifests dark (executor: agent)

- New `modules/nixos/k3s-monitoring.nix` (registered in `default.nix`,
  NOT enabled anywhere yet): 3 StatefulSets + 1 Deployment, PVCs
  (local-path, sizes TBD at seed), ClusterIP Services, NodePorts,
  ConfigMaps (prometheus.yml, loki.yaml, tempo.yaml, grafana.ini +
  provisioning, dashboards), plain Ingress for grafana (forward-auth
  ON) — all content, no activation.
- Config translated 1:1 from `containers/monitoring.nix` (flags,
  retentions, receivers, allowlists-as-docs). Datasource URLs use
  cluster Service names.
- Verify: `nix eval` renders all manifests; `nix build` of nas toplevel
  green; NO cluster objects created (module not enabled).

## Task 3 — Secrets live (executor: user + agent)

- User: populate `grafana-admin-password` + `grafana-secret-key` from
  Pass via secretspec (`-p kube -p pass` alias discipline); agent
  creates the Secrets in-cluster and verifies keys exist.
- Agent: wire `env`/`valueFrom` + `$__file__` equivalents (Grafana
  reads secret files: mount Secrets as files at the same paths the
  NixOS module used).
- Verify: Secrets exist with both keys; Grafana Deployment references
  them (eval).

## Task 4 — Seed state (executor: user + agent)

- User (on nas, old container STOPPED briefly for clean copies — or
  Prometheus snapshot API if admin-api available; Loki/Tempo/Grafana
  are file copies):
  `du -sh` the four state dirs (record sizes), snapshot/copy to staging,
  agent `chown -R <image-uid>:<image-gid>`, move into the new PVC
  paths (local-path provisioner dirs, claimRefs verified).
- Agent: PVC manifests with matching sizes + `volumeName` pins (avoid
  the nextcloud lottery lesson).
- Verify: file counts + sizes match source; permissions match image UIDs.

## Task 5 — Backends live + dual-write warmup (executor: agent + user)

- Agent: enable module on nas, switch, verify 4 pods Running + probes.
- User: flip agent endpoints to dual-write (homelab IP + module
  defaults gain the new NodePort endpoints ALONGSIDE the old),
  switch agents over ~1 day.
- Both: parity check — same series in both Prometheis (`count(up)` per
  job), same Loki streams, Tempo spans flowing.
- Verify: new-stack queries return data for every canary host; old
  stack untouched and still complete.

## Task 6 — Flip reads + UI, retire (executor: agent + user)

- Agent: Grafana datasources already point at new backends (Task 2);
  verify dashboards render from new data; add plain Ingress +
  REMOVE homelab edge-route entry in the same switch (no dual-router
  window); verify UI 200 through the gate.
- User: round-trip — browse dashboards, run an ad-hoc PromQL/LogQL/
  TraceQL query per backend, confirm admin login works.
- Agent: container `enable = false`, agents drop old endpoints
  (second agents switch), old ports verified dead, POOL state retained.
- Verify: single router on the vhost; all agents reporting to new
  endpoints only (`up` cardinality matches host count); old container
  unit dead.

## Rollback (any task)

- Reads: point Grafana datasources back (one switch) — old stack kept
  receiving throughout warmup, zero gap.
- Writes: agents still carry the old endpoints until Task 6 closes
  them out; re-adding is one revert.
- Nuclear: container `enable = true` + homelab IP back; POOL state
  never deleted until green + 1 week.

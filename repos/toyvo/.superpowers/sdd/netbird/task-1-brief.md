# Task 1 brief — pins + UIDs (2026-11-18)

NetBird images (all hub-verified 200):
- `netbirdio/management:0.83.1` (matches latest stable release v0.83.1) — user `` (root)
- `netbirdio/signal:0.83.1` — user `0` (root)
- `netbirdio/relay:0.83.1` — user `0` (root)
- `netbirdio/dashboard:v2.97.0` — user `` (root)

Dashboard note: the dashboard versions INDEPENDENTLY (v2.x line — no
0.83.1 tag exists; tags are otherwise commit SHAs). v2.97.0 is the
latest v2.x at check time. Pairing risk with management 0.83.1 is LOW
(stable management API) but real — verified at deploy time (an
incompatible dashboard fails fast and visibly, not silently).
Upstream's own getting-started defaults to `:latest` for these;
we pin per repo policy (no drift).

All four run as root — no seed chown needed (state PVCs root-owned is
fine). Management state backend: sqlite on local-path (small deploy,
no extra Postgres — decided in design, confirm the 0.83.1 management
image documents sqlite support at Task 2 build; upstream supports
`--disable-anonymous-metrics` + sqlite store type via flags).

Next: Task 2 — `modules/nixos/k3s-netbird.nix` dark (4 Deployments +
Services + management PVC + secrets wiring + dashboard Ingress
(forward-auth OFF) + relay/signal NodePorts for public UDP). Secrets
contract `k8s/netbird/secretspec.toml` alongside.

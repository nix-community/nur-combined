# Grafana Observability Stack — Design Spec

## Goal

Full observability (metrics, logs, alerting) across 8 NixOS machines using a NAS-centric Grafana/Prometheus/Loki stack with Grafana Alloy as the unified agent.

## Fleet

| Machine      | Role                                                   | IP                                | Architecture  |
| ------------ | ------------------------------------------------------ | --------------------------------- | ------------- |
| NAS          | Hub (Grafana, Prometheus, Loki) + services             | 10.1.0.3                          | x86_64-linux  |
| Router       | Network, Caddy reverse proxy, DHCP, WireGuard endpoint | 10.1.0.1                          | x86_64-linux  |
| Protectli    | Network, firewall, VLANs                               | 10.1.0.6                          | x86_64-linux  |
| Oracle Cloud | Game servers, Caddy                                    | 149.130.210.149 / 10.100.0.2 (WG) | aarch64-linux |
| rpi4b4a      | Edge node                                              | 10.1.0.10                         | aarch64-linux |
| rpi4b8a      | Edge node                                              | 10.1.0.7                          | aarch64-linux |
| rpi4b8b      | Edge node                                              | 10.1.0.8                          | aarch64-linux |
| rpi4b8c      | Edge node                                              | 10.1.0.9                          | aarch64-linux |

**Excluded:** All Darwin machines, laptops (MacBooks, PineBook, HP-Envy, HP-ZBook, Thinkpad), steamdeck-nixos, WSL.

## Architecture

### Central Stack (NAS)

- **Grafana** (:3000) — dashboards, alerting, visualization. Accessible via `grafana.diekvoss.net` through Router's Caddy reverse proxy.
- **Prometheus** (:9090) — metrics storage, scrapes all targets. Cockpit moves to :9091 to free this port.
- **Loki** (:3100) — log aggregation. Authenticated via shared bearer token, multi-tenant via `X-Scope-OrgID` header per machine.
- **Alloy** — local agent for NAS's own metrics and logs

### Agents (All Monitored Machines)

Every monitored machine runs **Grafana Alloy**, which:

- Exposes node metrics on a `/metrics` endpoint (:12345) for Prometheus to scrape
- Reads the systemd journal and pushes logs to Loki on the NAS with bearer token auth
- Sends `X-Scope-OrgID: <hostname>` header for Loki multi-tenancy
- Optionally scrapes service-specific metrics (Caddy, game servers, etc.)

### Network Connectivity

- **LAN machines** (Router, Protectli, RPis): Prometheus scrapes directly over 10.1.0.x
- **Oracle Cloud**: WireGuard tunnel terminated on the **Router** (10.1.0.1)
  - Router: 10.100.0.1 (WireGuard server, interface `wg0`, listens :51820)
  - Oracle: 10.100.0.2 (WireGuard peer, interface `wg0`)
  - Router forwards traffic between WG subnet (10.100.0.0/24) and LAN (10.1.0.0/24)
  - Prometheus on NAS scrapes Oracle via 10.100.0.2 (routed through Router)
  - Alloy on Oracle pushes logs to 10.1.0.3:3100 (routed through Router)
  - No NAT/port-forward needed — Router terminates the tunnel directly
  - Router must open 51820/UDP on WAN interface (`enp2s0.allowedUDPPorts`)
  - Router must add `wg0` to `networking.nat.internalInterfaces` for WG↔LAN forwarding
  - WireGuard private keys managed via sops-nix

**Existing WireGuard on NAS:** The NAS has a ProtonVPN tunnel currently on `wg0` with a network namespace (`protonvpn0`). This will be renamed to `wg-proton`. All namespace references, routes, and pre/post setup scripts in `systems/nas/wireguard.nix` must be updated in lockstep with the interface rename. The new monitoring/general-purpose tunnel lives on the Router, not the NAS.

### Prometheus Scrape Target Generation

Scrape targets are generated from `homelab.nix` data rather than hardcoded. The `homelab.nix` file already contains all machine IPs and service definitions. The Prometheus module reads this data to build the static target list, keeping the source of truth in one place.

**Note:** The Oracle machine's `homelab.nix` key is `oracle` but its NixOS hostname is `oracle-cloud-nixos`. The monitoring module must handle this mismatch — either by fixing `homelab.nix` to use the actual hostname as the key, or by providing a mapping. Recommend renaming the key to `oracle-cloud-nixos` for consistency. The `X-Scope-OrgID` tenant header and scrape target labels should use the NixOS hostname.

RPi entries in `homelab.nix` have IPs but no `services` attribute. The monitoring module must still generate Alloy scrape targets for machines without services.

## NixOS Module Structure

```
modules/nixos/
├── monitoring/
│   ├── default.nix          # Alloy agent (enable on any machine)
│   ├── grafana.nix           # Grafana server (NAS only)
│   ├── prometheus.nix        # Prometheus server (NAS only)
│   └── loki.nix              # Loki server (NAS only)
├── wireguard/
│   └── default.nix           # WireGuard tunnel (Router + Oracle, general purpose)
```

**Module import pattern:** Modules under `modules/nixos/` are available via `self.modules.nixos.*` but must be **explicitly imported** in each machine's `configuration.nix`. There is no auto-import into system configs.

For example:

- NAS imports: `monitoring/default.nix`, `monitoring/grafana.nix`, `monitoring/prometheus.nix`, `monitoring/loki.nix`
- Router imports: `monitoring/default.nix`, `wireguard/default.nix`
- Oracle imports: `monitoring/default.nix`, `wireguard/default.nix`
- Protectli, RPis import: `monitoring/default.nix`

The WireGuard module is placed under `modules/nixos/wireguard/` (not under `monitoring/`) because it is general-purpose — useful for future point-to-point tunnels beyond monitoring.

### Module Behavior

**`monitoring/default.nix`** — Shared Alloy agent module:

- Option: `services.monitoring.enable = true`
- Configures Alloy to collect node metrics and ship journal logs
- Detects enabled services (Caddy, PostgreSQL, etc.) and adds appropriate scrape configs
- Parameterized with Loki push URL (defaults to NAS IP from homelab.nix)
- Sends bearer token (from sops-nix) and `X-Scope-OrgID: <hostname>` with log pushes

**`monitoring/grafana.nix`** — Grafana server:

- Auto-provisioned datasources: Prometheus (localhost:9090) + Loki (localhost:3100)
- Auto-provisioned dashboards: Node Exporter Full, Loki Logs Explorer
- Admin password via sops-nix
- Listens on :3000
- Registered in `homelab.nix` under `nas.services.grafana`
- Caddy virtual host `grafana.diekvoss.net` added to Router's `virtual-hosts.nix`

**`monitoring/prometheus.nix`** — Prometheus server:

- Scrape interval: 15s
- Retention: 30 days
- Storage: `/var/lib/prometheus2/`
- Scrape targets: Generated from `homelab.nix` machine IPs

**`monitoring/loki.nix`** — Loki server:

- Retention: 14 days
- Storage: `/var/lib/loki/`
- Loki listens on localhost:3100 (not exposed directly)
- Multi-tenant mode enabled (`auth_enabled: true`)
- Nginx or Caddy reverse proxy on :3100 validates `Authorization: Bearer <token>` header before proxying to Loki (Loki has no native bearer token support)
- Alloy agents send `Authorization: Bearer <token>` + `X-Scope-OrgID: <hostname>` headers

**`wireguard/default.nix`** — WireGuard tunnel:

- Subnet: 10.100.0.0/24
- Router: 10.100.0.1 (server, interface `wg0`, listen :51820)
- Oracle: 10.100.0.2 (peer, interface `wg0`)
- Router configured to forward between WG and LAN subnets
- Private keys via sops-nix

## Data Flow

### Metrics

```
[Alloy on each machine] --expose :12345/metrics-->
[Prometheus on NAS] --scrape every 15s--> [local TSDB, 30d retention]
[Grafana] --query--> [Prometheus]
```

### Logs

```
[Alloy on each machine] --read systemd journal-->
  --push with bearer token + X-Scope-OrgID: <hostname>-->
  [Loki on NAS :3100]
[Grafana] --query--> [Loki]
```

Labels applied to logs: `host`, `unit` (systemd service), `priority` (log level).

### Oracle Cloud Traffic Path

```
[Alloy on Oracle] --10.100.0.2-->
  [WireGuard tunnel] --10.100.0.1-->
  [Router] --forwards to 10.1.0.3-->
  [NAS Loki/Prometheus]
```

## Service-Specific Metrics

### NAS

- **PostgreSQL**: `services.prometheus.exporters.postgres` — connections, query stats
- **Jellyfin**: Third-party Prometheus plugin (requires manual install via Jellyfin UI)
- **Nextcloud**: `services.prometheus.exporters.nextcloud`
- **Immich**: `/api/server-info` custom scrape (requires API key, stored in sops-nix)
- **Home Assistant**: Built-in Prometheus integration
- **Podman containers**: Alloy `discovery.docker` (requires Alloy user in podman socket group)
- **Ollama**: `/api/tags` health check

### Router

- **Caddy**: Built-in Prometheus metrics (`metrics` global option)
- **Kea DHCP**: `services.prometheus.exporters.kea` — lease counts, pool utilization
- **nftables**: node-exporter `nf_conntrack` collector + nftables counters

### Protectli

- **nftables**: Same as Router
- **Network interfaces**: Per-interface bytes/packets via Alloy node metrics (VLAN visibility)

### Oracle Cloud

- **Caddy**: Built-in Prometheus metrics
- **Minecraft**: Community `minecraft-exporter` — player count, TPS, memory
- **Vintage Story**: Deferred to later phase — no established exporter, would require custom log parsing

### RPis

- Node metrics + journal logs only (basic health monitoring)
- Prometheus marks them as down when offline

## Alerting

Grafana built-in alerting (Phase 4):

- Disk usage > 85%
- Service down (target unreachable)
- High CPU sustained > 90% for 5m
- WireGuard tunnel down
- Log error rate spikes

Email notification channel initially. No external notification services.

## Incremental Build Order

### Phase 1 — Central Stack on NAS

1. Move Cockpit from :9090 to :9091 (change `homelab.nix` `cockpit.port`, NAS config reads from there)
1. Grafana + Prometheus + Loki NixOS modules
1. Alloy on NAS (self-monitoring)
1. Auto-provisioned datasources (Prometheus + Loki)
1. Node Exporter Full dashboard
1. Register Grafana in `homelab.nix`

### Phase 2 — LAN Agents + Reverse Proxy

7. Alloy module deployed to Router, Protectli
1. Prometheus scrape targets generated from homelab.nix
1. Caddy metrics on Router
1. nftables/Kea DHCP metrics on Router
1. Caddy virtual host `grafana.diekvoss.net` on Router

### Phase 3 — WireGuard + Oracle

12. Rename NAS ProtonVPN interface from `wg0` to `wg-proton` (update all namespace/route refs in `systems/nas/wireguard.nix`)
1.  WireGuard module on Router (server) + Oracle (peer)
1.  Open 51820/UDP on Router WAN interface (`enp2s0`)
1.  Add `wg0` to Router's `networking.nat.internalInterfaces` for WG↔LAN forwarding
1.  Alloy on Oracle
1.  Caddy, Minecraft metrics on Oracle

### Phase 4 — RPis + Polish

17. Alloy on RPi nodes
1.  Service-specific dashboards (Jellyfin, Nextcloud, Immich, etc.)
1.  Grafana alerting rules

## Secrets (sops-nix)

All secrets stored in `secrets.yaml`, encrypted with age keys per machine.

| Secret Name                    | Used By                         | How to Generate                          |
| ------------------------------ | ------------------------------- | ---------------------------------------- |
| `grafana-admin-password`       | NAS (Grafana)                   | `openssl rand -base64 32`                |
| `loki-bearer-token`            | NAS (Loki) + all agents (Alloy) | `openssl rand -hex 32`                   |
| `wireguard-router-private-key` | Router (WireGuard server)       | `wg genkey`                              |
| `wireguard-oracle-private-key` | Oracle (WireGuard peer)         | `wg genkey`                              |
| `immich-api-key`               | NAS (Prometheus scrape)         | Generate in Immich UI → Admin → API Keys |

**WireGuard key generation:**

```bash
# Generate Router keypair
wg genkey | tee router-private.key | wg pubkey > router-public.key

# Generate Oracle keypair
wg genkey | tee oracle-private.key | wg pubkey > oracle-public.key

# Add private keys to sops secrets
sops secrets.yaml
# Add:
#   wireguard-router-private-key: <contents of router-private.key>
#   wireguard-oracle-private-key: <contents of oracle-private.key>

# Public keys go directly in the WireGuard module config (not secret)
# Clean up plaintext keys
rm router-private.key oracle-private.key
# Keep public keys for reference or note them in the module

cat router-public.key   # → put in Oracle's peer config
cat oracle-public.key   # → put in Router's peer config
```

**Grafana admin password:**

```bash
openssl rand -base64 32
sops secrets.yaml
# Add:
#   grafana-admin-password: <generated password>
```

**Loki bearer token:**

```bash
openssl rand -hex 32
sops secrets.yaml
# Add:
#   loki-bearer-token: <generated token>
```

**Immich API key:**

```
# Generate in Immich web UI: Administration → API Keys → New API Key
sops secrets.yaml
# Add:
#   immich-api-key: <key from Immich UI>
```

**sops.yaml key assignments:**

- `grafana-admin-password`: NAS only
- `loki-bearer-token`: NAS, Router, Protectli, Oracle, rpi4b4a, rpi4b8a, rpi4b8b, rpi4b8c (all machines running Alloy)
- `wireguard-router-private-key`: Router only
- `wireguard-oracle-private-key`: Oracle only
- `immich-api-key`: NAS only (Phase 4)

## Firewall Changes

| Machine    | Port  | Protocol | Direction        | Purpose                              |
| ---------- | ----- | -------- | ---------------- | ------------------------------------ |
| NAS        | 3000  | TCP      | Inbound (LAN)    | Grafana UI                           |
| NAS        | 9090  | TCP      | Inbound (LAN)    | Prometheus (optional, for debugging) |
| NAS        | 9091  | TCP      | Inbound (LAN)    | Cockpit (moved from 9090)            |
| NAS        | 3100  | TCP      | Inbound (LAN)    | Loki push endpoint                   |
| Router     | 51820 | UDP      | Inbound (WAN)    | WireGuard tunnel                     |
| All agents | 12345 | TCP      | Inbound (LAN/WG) | Alloy metrics endpoint               |
| Router     | 9547  | TCP      | Inbound (LAN)    | Kea exporter                         |

## Notes

- **Disk space**: With 8 machines at 15s scrape intervals and 30d/14d retention, expect ~1-2GB for Prometheus and ~2-5GB for Loki depending on log volume. Both use `/var/lib/` on the NAS root filesystem. If space becomes an issue, consider moving to `/mnt/POOL`.
- **Vintage Story monitoring**: Deferred beyond Phase 4. No established Prometheus exporter exists; would require custom log parsing which is fragile.
- **Jellyfin metrics**: Requires manual plugin installation through the Jellyfin web UI — not declaratively managed by NixOS.
- **Podman socket access**: Alloy service user needs to be added to the podman socket group for container discovery to work.

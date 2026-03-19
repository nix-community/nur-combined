# Grafana Observability Stack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Full metrics/logs/alerting across 8 NixOS machines using Grafana, Prometheus, Loki, and Grafana Alloy agents, with a WireGuard tunnel from the Router to Oracle Cloud.

**Architecture:** NAS-centric hub runs Grafana (:3000), Prometheus (:9090), and Loki (:3100). Every monitored machine runs Grafana Alloy which pushes metrics via remote_write and pushes journal logs to Loki. Oracle Cloud connects via WireGuard tunnel terminated on the Router. Loki uses `auth_enabled: false` (simpler for homelab) with nginx IP-based access control + `X-Scope-OrgID` headers for tenant labeling.

**Design decisions (deviations from spec):**

- **Push-only metrics:** Alloy pushes via `prometheus.remote_write` rather than exposing `/metrics` for Prometheus to scrape. Simpler — no need to open port 12345 on every machine.
- **Loki auth:** Simplified from bearer token to nginx IP allowlist (LAN + WireGuard subnet). `auth_enabled: false` so Grafana can query all tenants. `X-Scope-OrgID` still used for labeling/isolation.
- **WireGuard rename in Phase 1:** Moved from spec's Phase 3 to Phase 1 to prevent `wg0` conflicts.
- **Dashboards and service exporters:** Deferred to future work (not in this plan).

**Tech Stack:** NixOS modules (Nix), Grafana, Prometheus, Loki, Grafana Alloy, WireGuard, nginx, sops-nix

**Spec:** `docs/superpowers/specs/2026-03-18-grafana-observability-design.md`

---

## File Map

### New Files

| File                                      | Responsibility                                                 |
| ----------------------------------------- | -------------------------------------------------------------- |
| `modules/nixos/monitoring/default.nix`    | Shared Alloy agent module — enable on any machine              |
| `modules/nixos/monitoring/grafana.nix`    | Grafana server config (NAS only)                               |
| `modules/nixos/monitoring/prometheus.nix` | Prometheus server + scrape targets from homelab.nix (NAS only) |
| `modules/nixos/monitoring/loki.nix`       | Loki server + nginx IP-allowlist proxy (NAS only)              |
| `modules/nixos/wireguard/default.nix`     | WireGuard tunnel config (Router + Oracle)                      |

### Modified Files

| File                                           | Changes                                                                                                                |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `homelab.nix`                                  | Add `grafana` service under `nas.services`, rename `oracle` key to `oracle-cloud-nixos`, update `cockpit.port` to 9091 |
| `systems/nas/configuration.nix`                | Import monitoring modules, add firewall ports, add sops secrets                                                        |
| `systems/nas/wireguard.nix`                    | Rename `wg0` → `wg-proton` throughout                                                                                  |
| `systems/router/configuration.nix`             | Import monitoring + wireguard modules, add firewall ports, add NAT internal interface, add sops secrets                |
| `systems/router/virtual-hosts.nix`             | No changes needed — auto-generates from homelab.nix                                                                    |
| `systems/oracle-cloud-nixos/configuration.nix` | Import monitoring + wireguard modules, add firewall ports, add sops secrets                                            |
| `systems/Protectli/configuration.nix`          | Import monitoring module, add firewall ports, add sops secrets                                                         |
| `systems/rpi4b4a/configuration.nix`            | Import monitoring module, add firewall ports, add sops secrets                                                         |
| `systems/rpi4b8a/configuration.nix`            | Import monitoring module, add firewall ports, add sops secrets                                                         |
| `systems/rpi4b8b/configuration.nix`            | Import monitoring module, add firewall ports, add sops secrets                                                         |
| `systems/rpi4b8c/configuration.nix`            | Import monitoring module, add firewall ports, add sops secrets                                                         |
| `.sops.yaml`                                   | No changes needed — single key group already covers all machines                                                       |

---

## Phase 1 — Central Stack on NAS

### Task 1: Update homelab.nix (Cockpit port + Grafana + Oracle rename)

**Files:**

- Modify: `homelab.nix:117-124` (cockpit port)

- Modify: `homelab.nix:369-380` (rename oracle → oracle-cloud-nixos)

- Modify: `homelab.nix:46-272` (add grafana service under nas)

- [ ] **Step 1: Change Cockpit port from 9090 to 9091**

In `homelab.nix`, change the cockpit service:

```nix
cockpit = {
  port = 9091;
  selfSigned = true;
  displayName = "Cockpit";
  description = "Server Management";
  category = "DevOps";
  icon = "sh-cockpit";
};
```

- [ ] **Step 2: Add Grafana service under nas.services**

Add after the `cockpit` entry in `homelab.nix`:

```nix
grafana = {
  port = 3000;
  displayName = "Grafana";
  description = "Observability Dashboards";
  category = "DevOps";
  icon = "sh-grafana";
};
```

- [ ] **Step 3: Rename oracle key to oracle-cloud-nixos**

In `homelab.nix`, rename the `oracle` key at line 369:

```nix
oracle-cloud-nixos = {
  ip = "149.130.210.149";
  services.minecraft = {
    port = 7878;
    subdomain = "mc";
    domain = "toyvo.dev";
    category = "Games";
    displayName = "Minecraft";
    description = "Minecraft Server";
    icon = "sh-minecraft";
  };
};
```

- [ ] **Step 4: Verify evaluation**

Run: `nix flake show --no-build 2>&1 | head -50`
Expected: No errors. The virtual-hosts.nix filters by `10.1.0.*` prefix so oracle-cloud-nixos (149.130.210.149) is already excluded from Caddy — no breakage. The `oracle-cloud-nixos` rename may break references if any module uses `homelab.oracle` — search for it:

Run: `grep -r 'homelab\.oracle' systems/ modules/`
Expected: No matches (oracle config doesn't reference homelab.oracle since it doesn't use `homelab.${hostName}` — its hostname is `oracle-cloud-nixos` which didn't match the old `oracle` key anyway).

- [ ] **Step 5: Commit**

```bash
git add homelab.nix
git commit -m "prep: move cockpit to 9091, add grafana service, rename oracle key"
```

---

### Task 2: Rename NAS ProtonVPN WireGuard interface

**Files:**

- Modify: `systems/nas/wireguard.nix`

- [ ] **Step 1: Rename wg0 to wg-proton**

Replace the entire `systems/nas/wireguard.nix` content. The only change is `wireguardInterface = "wg0"` → `wireguardInterface = "wg-proton"`:

```nix
{
  config,
  ...
}:
let
  wireguardInterface = "wg-proton";
  wireguardInterfaceNamespace = "protonvpn0";
  wireguardGateway = "10.2.0.1";
in
{
  config = {
    sops.secrets."protonvpn-US-IL-503.key" = { };
    networking.wireguard.interfaces.${wireguardInterface} = {
      privateKeyFile = config.sops.secrets."protonvpn-US-IL-503.key".path;
      ips = [ "10.2.0.2/32" ];
      peers = [
        {
          publicKey = "Ad0UnBi3NeIgVpM1baC8HAp6wfSli0wGS1OCmS7uYRo=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "79.127.187.156:51820";
        }
      ];
      interfaceNamespace = wireguardInterfaceNamespace;
      preSetup = ''ip netns add "${wireguardInterfaceNamespace}"'';
      postSetup = ''
        ip -n "${wireguardInterfaceNamespace}" link set up dev "lo"
        ip -n "${wireguardInterfaceNamespace}" route add default dev "${wireguardInterface}"
      '';
      preShutdown = ''ip -n "${wireguardInterfaceNamespace}" route del default dev "${wireguardInterface}"'';
      postShutdown = ''ip netns del "${wireguardInterfaceNamespace}"'';
    };
    environment.etc."netns/${wireguardInterfaceNamespace}/resolv.conf".text =
      "nameserver ${wireguardGateway}";
  };
}
```

- [ ] **Step 2: Verify evaluation**

Run: `nix eval .#nixosConfigurations.nas.config.networking.wireguard.interfaces --json 2>&1 | head -5`
Expected: Shows `wg-proton` as the interface key, not `wg0`.

- [ ] **Step 3: Commit**

```bash
git add systems/nas/wireguard.nix
git commit -m "rename NAS ProtonVPN wireguard interface from wg0 to wg-proton"
```

---

### Task 3: Create Alloy agent module (monitoring/default.nix)

**Files:**

- Create: `modules/nixos/monitoring/default.nix`

- [ ] **Step 1: Create the module directory**

Run: `mkdir -p modules/nixos/monitoring`

- [ ] **Step 2: Write the Alloy agent module**

Create `modules/nixos/monitoring/default.nix`:

```nix
{
  config,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  cfg = config.services.monitoring;
  lokiUrl = "http://${homelab.nas.ip}:3100/loki/api/v1/push";
  prometheusUrl = "http://${homelab.nas.ip}:9090/api/v1/write";
  hostname = config.networking.hostName;

  # Escape Nix interpolation in Alloy config (Alloy uses ${} too)
  alloyConfig = ''
    // Node metrics — push to Prometheus via remote_write
    prometheus.exporter.unix "node" {
      disable_collectors = ["mdadm"]
    }

    prometheus.scrape "node" {
      targets    = prometheus.exporter.unix.node.targets
      forward_to = [prometheus.relabel.instance.receiver]
      scrape_interval = "15s"
    }

    prometheus.relabel "instance" {
      rule {
        target_label = "instance"
        replacement  = "${hostname}"
      }
      forward_to = [prometheus.remote_write.default.receiver]
    }

    prometheus.remote_write "default" {
      endpoint {
        url = "${prometheusUrl}"
      }
    }

    // Journal log collection — push to Loki
    loki.source.journal "systemd" {
      forward_to = [loki.relabel.journal.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels = {
        host = "${hostname}",
      }
    }

    loki.relabel "journal" {
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "priority"
      }
      forward_to = [loki.write.default.receiver]
    }

    loki.write "default" {
      endpoint {
        url = "${cfg.lokiPushUrl}"
        headers = {
          "X-Scope-OrgID" = "${hostname}",
        }
      }
    }
  '';
in
{
  options.services.monitoring = {
    enable = lib.mkEnableOption "monitoring agent (Grafana Alloy)";

    lokiPushUrl = lib.mkOption {
      type = lib.types.str;
      default = lokiUrl;
      description = "Loki push API URL";
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      extraFlags = [ "--stability.level=generally-available" ];
    };

    # Alloy needs to read the journal
    users.users.alloy.extraGroups = [ "systemd-journal" ];

    environment.etc."alloy/config.alloy".text = alloyConfig;

    # No firewall ports needed — Alloy only pushes (no scrape endpoint exposed)
  };
}
```

**Key design decisions:**

- **Push-only metrics:** Alloy pushes via `prometheus.remote_write` to Prometheus. No `/metrics` endpoint exposed, no port 12345 needed. This eliminates the need to open firewall ports on every machine and avoids dual-collection (push + pull).

- **No bearer token for Loki:** Removed — Loki auth is handled by nginx IP allowlist on the NAS (see Task 5). Simpler and avoids the sops EnvironmentFile KEY=VALUE format issue.

- **Alloy config Nix interpolation:** `${hostname}` is resolved at Nix eval time, not by Alloy. The Alloy River config uses `${}` syntax too, but since we're embedding hostname as a literal string at build time, this works correctly.

- [ ] **Step 3: Verify the module evaluates**

We can't fully test yet (Alloy won't find config), but verify syntax:

Run: `nix eval --expr 'let pkgs = import <nixpkgs> {}; in builtins.typeOf (import ./modules/nixos/monitoring/default.nix)' 2>&1`
Expected: `"lambda"` (it's a valid NixOS module function)

- [ ] **Step 4: Commit**

```bash
git add modules/nixos/monitoring/default.nix
git commit -m "feat: add Grafana Alloy agent module (monitoring/default.nix)"
```

---

### Task 4: Create Prometheus module (monitoring/prometheus.nix)

**Files:**

- Create: `modules/nixos/monitoring/prometheus.nix`

- [ ] **Step 1: Write the Prometheus server module**

Create `modules/nixos/monitoring/prometheus.nix`:

```nix
{
  config,
  lib,
  ...
}:
{
  options.services.monitoring.prometheus = {
    enable = lib.mkEnableOption "Prometheus server";
  };

  config = lib.mkIf config.services.monitoring.prometheus.enable {
    services.prometheus = {
      enable = true;
      port = 9090;
      retentionTime = "30d";

      # Enable remote write receiver — Alloy agents push metrics here
      extraFlags = [ "--web.enable-remote-write-receiver" ];

      # No scrapeConfigs needed — all metrics arrive via remote_write from Alloy
      # The `instance` label is set by Alloy's relabel rule on each machine
    };

    networking.firewall.allowedTCPPorts = [ 9090 ];
  };
}
```

**Note:** With push-only architecture, Prometheus has no scrape targets. All metrics arrive via Alloy's `prometheus.remote_write`. This eliminates the B1 blocker (Protectli hostname case mismatch) since the `instance` label is set by Alloy using `config.networking.hostName` on each machine, not from homelab.nix keys. It also means no port 12345 needs to be opened on any machine.

- [ ] **Step 2: Commit**

```bash
git add modules/nixos/monitoring/prometheus.nix
git commit -m "feat: add Prometheus server module with homelab.nix target generation"
```

---

### Task 5: Create Loki module with nginx auth proxy (monitoring/loki.nix)

**Files:**

- Create: `modules/nixos/monitoring/loki.nix`

- [ ] **Step 1: Write the Loki server module**

Create `modules/nixos/monitoring/loki.nix`:

```nix
{
  config,
  lib,
  homelab,
  ...
}:
{
  options.services.monitoring.loki = {
    enable = lib.mkEnableOption "Loki log aggregation server";
  };

  config = lib.mkIf config.services.monitoring.loki.enable {
    services.loki = {
      enable = true;
      configuration = {
        # auth_enabled = false so Grafana can query all tenants
        # X-Scope-OrgID headers still used for labeling but not enforced
        auth_enabled = false;

        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = 3101; # Internal port, nginx proxies 3100 → 3101
        };

        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/var/lib/loki";
        };

        schema_config.configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        storage_config.filesystem.directory = "/var/lib/loki/chunks";

        limits_config = {
          retention_period = "336h"; # 14 days
          allow_structured_metadata = false;
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          delete_request_cancel_period = "10m";
          retention_delete_delay = "2h";
        };
      };
    };

    # Nginx reverse proxy on :3100 with IP-based access control
    # Only allows LAN (10.1.0.0/24), WireGuard (10.100.0.0/24), and localhost
    services.nginx = {
      enable = true;
      virtualHosts."loki-gateway" = {
        listen = [
          { addr = "0.0.0.0"; port = 3100; }
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:3101";
          extraConfig = ''
            allow 127.0.0.1;
            allow 10.1.0.0/24;
            allow 10.100.0.0/24;
            deny all;

            proxy_set_header X-Scope-OrgID $http_x_scope_orgid;
          '';
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 3100 ];
  };
}
```

**Design decisions:**

- **`auth_enabled = false`**: Simplifies Grafana's ability to query all hosts' logs. With `auth_enabled = true`, Grafana can only query one tenant at a time, which makes cross-host log correlation painful. The `X-Scope-OrgID` header is still sent by Alloy agents for labeling.

- **Nginx IP allowlist instead of bearer token**: Much simpler to implement with NixOS/sops-nix. Loki has no native bearer token support, and wiring sops secrets into nginx config snippets is fragile. IP allowlist is sufficient for a homelab where you control the network.

- **Loki on localhost:3101, nginx on 0.0.0.0:3100**: Loki never exposed directly. Nginx gates access.

- [ ] **Step 2: Commit**

```bash
git add modules/nixos/monitoring/loki.nix
git commit -m "feat: add Loki server module with nginx auth proxy"
```

---

### Task 6: Create Grafana module (monitoring/grafana.nix)

**Files:**

- Create: `modules/nixos/monitoring/grafana.nix`

- [ ] **Step 1: Write the Grafana server module**

Create `modules/nixos/monitoring/grafana.nix`:

```nix
{
  config,
  lib,
  homelab,
  ...
}:
let
  cfg = config.services.monitoring;
  inherit (config.networking) hostName;
in
{
  options.services.monitoring.grafana = {
    enable = lib.mkEnableOption "Grafana dashboard server";
  };

  config = lib.mkIf cfg.grafana.enable {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = homelab.${hostName}.services.grafana.port;
          domain = "grafana.diekvoss.net";
          root_url = "https://grafana.diekvoss.net";
        };
        security = {
          admin_user = "admin";
          admin_password = "$__file{${config.sops.secrets."grafana-admin-password".path}}";
        };
      };

      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
            access = "proxy";
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:3101"; # Direct to Loki, skip nginx (same machine)
            access = "proxy";
            # No X-Scope-OrgID needed — auth_enabled=false, Grafana sees all logs
          }
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      (homelab.${hostName}.services.grafana.port)
    ];
  };
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/nixos/monitoring/grafana.nix
git commit -m "feat: add Grafana server module with auto-provisioned datasources"
```

---

### Task 7: Wire up NAS configuration

**Files:**

- Modify: `systems/nas/configuration.nix`

- [ ] **Step 1: Add monitoring module imports to NAS**

Add to the `imports` list in `systems/nas/configuration.nix` (after the existing module imports, before the `inputs.*` lines):

```nix
inputs.nixcfg.modules.nixos.monitoring.default
inputs.nixcfg.modules.nixos.monitoring.grafana
inputs.nixcfg.modules.nixos.monitoring.prometheus
inputs.nixcfg.modules.nixos.monitoring.loki
```

- [ ] **Step 2: Enable monitoring services**

Add to the `services` block in `systems/nas/configuration.nix`:

```nix
monitoring = {
  enable = true;
  grafana.enable = true;
  prometheus.enable = true;
  loki.enable = true;
};
```

- [ ] **Step 3: Add sops secrets**

Add to the `sops.secrets` block:

```nix
"grafana-admin-password" = {
  owner = "grafana";
  group = "grafana";
};
```

(No `loki-bearer-token` needed — Loki uses nginx IP allowlist instead of bearer token auth.)

- [ ] **Step 4: Add Loki port to firewall (3100)**

The monitoring modules handle their own firewall ports via `networking.firewall.allowedTCPPorts`, so no manual firewall changes needed in the NAS config.

- [ ] **Step 5: Verify evaluation**

Run: `nix eval .#nixosConfigurations.nas.config.services.grafana.enable 2>&1`
Expected: `true`

Run: `nix eval .#nixosConfigurations.nas.config.services.prometheus.enable 2>&1`
Expected: `true`

- [ ] **Step 6: Commit**

```bash
git add systems/nas/configuration.nix
git commit -m "feat: enable Grafana, Prometheus, Loki, and Alloy on NAS"
```

---

### Task 8: Format and full evaluation check

- [ ] **Step 1: Format all Nix files**

Run: `nix fmt`

- [ ] **Step 2: Full flake evaluation**

Run: `nix flake show --no-build 2>&1 | head -80`
Expected: All system configurations listed without errors.

- [ ] **Step 3: Commit formatting if needed**

```bash
git add -A
git commit -m "style: format nix files"
```

---

## Phase 2 — LAN Agents + Reverse Proxy

### Task 9: Deploy Alloy to Router

**Files:**

- Modify: `systems/router/configuration.nix`

- [ ] **Step 1: Add monitoring module import**

Add to imports in `systems/router/configuration.nix`:

```nix
inputs.nixcfg.modules.nixos.monitoring.default
```

- [ ] **Step 2: Enable monitoring**

Add to the config body:

```nix
services.monitoring.enable = true;
```

- [ ] **Step 3: Verify evaluation**

Run: `nix eval .#nixosConfigurations.router.config.services.alloy.enable 2>&1`
Expected: `true`

- [ ] **Step 4: Commit**

```bash
git add systems/router/configuration.nix
git commit -m "feat: enable Alloy monitoring agent on Router"
```

---

### Task 10: Deploy Alloy to Protectli

**Files:**

- Modify: `systems/Protectli/configuration.nix`

- [ ] **Step 1: Add monitoring module import**

Add to imports in `systems/Protectli/configuration.nix`:

```nix
inputs.nixcfg.modules.nixos.monitoring.default
```

- [ ] **Step 2: Enable monitoring**

Add:

```nix
services.monitoring.enable = true;
```

- [ ] **Step 3: Commit**

```bash
git add systems/Protectli/configuration.nix
git commit -m "feat: enable Alloy monitoring agent on Protectli"
```

---

### Task 11: Enable Caddy Prometheus metrics on Router

**Files:**

- Modify: `systems/router/configuration.nix`

- [ ] **Step 1: Add Caddy global metrics option**

In `systems/router/configuration.nix`, add to the `services.caddy` config:

```nix
services.caddy = {
  enable = true;
  globalConfig = ''
    servers {
      metrics
    }
  '';
};
```

This makes Caddy expose Prometheus metrics at `:2019/metrics` (Caddy's admin API default).

- [ ] **Step 2: Commit**

```bash
git add systems/router/configuration.nix
git commit -m "feat: enable Caddy Prometheus metrics on Router"
```

---

### Task 12: Add Grafana Caddy virtual host

**Files:**

- No changes needed — `virtual-hosts.nix` auto-generates from `homelab.nix`

Since we already added `grafana` under `nas.services` in homelab.nix (Task 1, Step 2), and the Router's `virtual-hosts.nix` auto-generates Caddy vhosts for all services on `10.1.0.*` IPs, the `grafana.diekvoss.net` virtual host will be created automatically.

- [ ] **Step 1: Verify the virtual host will be generated**

Run: `nix eval .#nixosConfigurations.router.config.services.caddy.virtualHosts --json 2>&1 | python3 -m json.tool | grep grafana`
Expected: Shows `grafana.diekvoss.net` with reverse proxy to `10.1.0.3:3000`

- [ ] **Step 2: Format and commit if any changes were needed**

Run: `nix fmt`

```bash
git add -A
git commit -m "style: format nix files"
```

---

## Phase 3 — WireGuard + Oracle

### Task 13: Create WireGuard module

**Files:**

- Create: `modules/nixos/wireguard/default.nix`

- [ ] **Step 1: Create the module directory**

Run: `mkdir -p modules/nixos/wireguard`

- [ ] **Step 2: Write the WireGuard module**

Create `modules/nixos/wireguard/default.nix`:

```nix
{
  config,
  lib,
  ...
}:
let
  cfg = config.services.wireguard-tunnel;
in
{
  options.services.wireguard-tunnel = {
    enable = lib.mkEnableOption "WireGuard point-to-point tunnel";

    role = lib.mkOption {
      type = lib.types.enum [ "server" "peer" ];
      description = "Whether this machine is the WireGuard server or a peer";
    };

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = "WireGuard listen port (server only)";
    };

    address = lib.mkOption {
      type = lib.types.str;
      description = "This machine's IP on the WireGuard subnet (e.g., 10.100.0.1/24)";
    };

    privateKeySecret = lib.mkOption {
      type = lib.types.str;
      description = "Name of the sops secret containing the WireGuard private key";
    };

    peerPublicKey = lib.mkOption {
      type = lib.types.str;
      description = "Public key of the remote peer";
    };

    peerEndpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Endpoint of the remote peer (host:port). Required for peer role.";
    };

    peerAllowedIPs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "AllowedIPs for the remote peer";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.wireguard.interfaces.wg0 = {
      ips = [ cfg.address ];
      listenPort = lib.mkIf (cfg.role == "server") cfg.listenPort;
      privateKeyFile = config.sops.secrets.${cfg.privateKeySecret}.path;
      peers = [
        ({
          publicKey = cfg.peerPublicKey;
          allowedIPs = cfg.peerAllowedIPs;
          persistentKeepalive = 25;
        } // lib.optionalAttrs (cfg.peerEndpoint != null) {
          endpoint = cfg.peerEndpoint;
        })
      ];
    };

    networking.firewall.allowedUDPPorts = lib.mkIf (cfg.role == "server") [
      cfg.listenPort
    ];
  };
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/nixos/wireguard/default.nix
git commit -m "feat: add WireGuard tunnel module (general purpose)"
```

---

### Task 14: Wire up WireGuard on Router

**Files:**

- Modify: `systems/router/configuration.nix`

- [ ] **Step 1: Add wireguard module import**

Add to imports:

```nix
inputs.nixcfg.modules.nixos.wireguard.default
```

- [ ] **Step 2: Configure WireGuard server**

Add to the config body:

```nix
services.wireguard-tunnel = {
  enable = true;
  role = "server";
  address = "10.100.0.1/24";
  privateKeySecret = "wireguard-router-private-key";
  peerPublicKey = "PLACEHOLDER_ORACLE_PUBLIC_KEY"; # Replace after key generation
  peerAllowedIPs = [ "10.100.0.2/32" ];
};
```

- [ ] **Step 3: Add wg0 to NAT internal interfaces**

Modify `networking.nat.internalInterfaces` to include `wg0`:

```nix
networking.nat.internalInterfaces = [
  "br0"
  "br0.20"
  "br0.30"
  "wg0"
];
```

- [ ] **Step 4: Open WireGuard port on WAN interface**

Add `51820` to `interfaces.enp2s0.allowedUDPPorts`:

```nix
interfaces.enp2s0 = {
  allowedTCPPorts = [
    80
    443
  ];
  allowedUDPPorts = [
    443
    51820
  ];
};
```

- [ ] **Step 5: Add sops secret**

Add to `sops.secrets`:

```nix
"wireguard-router-private-key" = { };
```

- [ ] **Step 6: Commit**

```bash
git add systems/router/configuration.nix
git commit -m "feat: configure WireGuard server on Router (wg0, 10.100.0.1)"
```

---

### Task 15: Wire up WireGuard on Oracle

**Files:**

- Modify: `systems/oracle-cloud-nixos/configuration.nix`

- [ ] **Step 1: Add wireguard and monitoring module imports**

Add to imports:

```nix
inputs.nixcfg.modules.nixos.wireguard.default
inputs.nixcfg.modules.nixos.monitoring.default
```

- [ ] **Step 2: Configure WireGuard peer**

Add to the config body:

```nix
services.wireguard-tunnel = {
  enable = true;
  role = "peer";
  address = "10.100.0.2/24";
  privateKeySecret = "wireguard-oracle-private-key";
  peerPublicKey = "PLACEHOLDER_ROUTER_PUBLIC_KEY"; # Replace after key generation
  peerEndpoint = "PLACEHOLDER_ROUTER_PUBLIC_IP:51820"; # Replace with Router's public IP or DDNS
  peerAllowedIPs = [ "10.100.0.0/24" "10.1.0.0/24" ];
};
```

Note: `peerAllowedIPs` includes both the WG subnet and the LAN subnet so Oracle can reach LAN services through the tunnel.

- [ ] **Step 3: Enable monitoring**

Add:

```nix
services.monitoring.enable = true;
```

- [ ] **Step 4: Add sops secrets**

Add to `sops.secrets`:

```nix
"wireguard-oracle-private-key" = { };
```

- [ ] **Step 5: Add Alloy metrics port to firewall**

The monitoring module handles this automatically via `networking.firewall.allowedTCPPorts`.

- [ ] **Step 6: Enable Caddy metrics on Oracle**

Oracle's Caddy config is inline. Add metrics to the global config:

```nix
services.caddy = {
  enable = true;
  email = "collin@diekvoss.com";
  globalConfig = ''
    servers {
      metrics
    }
  '';
  # ... existing virtualHosts ...
};
```

- [ ] **Step 7: Commit**

```bash
git add systems/oracle-cloud-nixos/configuration.nix
git commit -m "feat: configure WireGuard peer and Alloy on Oracle Cloud"
```

---

### Task 16: Format and evaluation check

- [ ] **Step 1: Format**

Run: `nix fmt`

- [ ] **Step 2: Evaluate all affected systems**

Run: `nix eval .#nixosConfigurations.router.config.networking.wireguard.interfaces.wg0.ips --json 2>&1`
Expected: `["10.100.0.1/24"]`

Run: `nix eval .#nixosConfigurations.oracle-cloud-nixos.config.services.alloy.enable 2>&1`
Expected: `true`

- [ ] **Step 3: Commit formatting**

```bash
git add -A
git commit -m "style: format nix files"
```

---

## Phase 4 — RPis + Polish

### Task 17: Deploy Alloy to RPi nodes

**Files:**

- Modify: `systems/rpi4b4a/configuration.nix`

- Modify: `systems/rpi4b8a/configuration.nix`

- Modify: `systems/rpi4b8b/configuration.nix`

- Modify: `systems/rpi4b8c/configuration.nix`

- [ ] **Step 1: Add monitoring to all RPi configs**

For each RPi configuration file, add to imports:

```nix
inputs.nixcfg.modules.nixos.monitoring.default
```

Add to config body:

```nix
services.monitoring.enable = true;
```

- [ ] **Step 2: Verify one RPi evaluates**

Run: `nix eval .#nixosConfigurations.rpi4b8a.config.services.alloy.enable 2>&1`
Expected: `true`

- [ ] **Step 3: Commit**

```bash
git add systems/rpi4b4a/configuration.nix systems/rpi4b8a/configuration.nix systems/rpi4b8b/configuration.nix systems/rpi4b8c/configuration.nix
git commit -m "feat: enable Alloy monitoring agent on all RPi nodes"
```

---

### Task 18: Final format and full evaluation

- [ ] **Step 1: Format everything**

Run: `nix fmt`

- [ ] **Step 2: Full flake show**

Run: `nix flake show --no-build 2>&1 | head -100`
Expected: All configurations listed without errors.

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "style: final formatting pass"
```

---

## Post-Implementation: Manual Steps

These steps require access to the actual machines and cannot be done in code alone:

### Secrets Generation

Run on a machine with sops access:

```bash
# 1. Generate WireGuard keys
wg genkey | tee /tmp/router-wg.key | wg pubkey > /tmp/router-wg.pub
wg genkey | tee /tmp/oracle-wg.key | wg pubkey > /tmp/oracle-wg.pub

# 2. Generate Grafana admin password
openssl rand -base64 32 > /tmp/grafana-pass.txt

# 3. Add to sops secrets
sops secrets.yaml
# Add these keys:
#   grafana-admin-password: <contents of /tmp/grafana-pass.txt>
#   wireguard-router-private-key: <contents of /tmp/router-wg.key>
#   wireguard-oracle-private-key: <contents of /tmp/oracle-wg.key>

# Then update placeholder public keys in code
# In systems/router/configuration.nix:
#   peerPublicKey = "<contents of /tmp/oracle-wg.pub>";
# In systems/oracle-cloud-nixos/configuration.nix:
#   peerPublicKey = "<contents of /tmp/router-wg.pub>";
#   peerEndpoint = "<router-public-ip>:51820";

# 4. Clean up plaintext keys
rm /tmp/router-wg.key /tmp/oracle-wg.key /tmp/grafana-pass.txt
# Keep the .pub files until you've updated the configs, then delete them too
```

### Deployment Order

1. Deploy NAS first (`nh os switch ~/nixcfg` on NAS) — brings up Grafana, Prometheus, Loki
1. Deploy Router — brings up Alloy agent + WireGuard server
1. Deploy Oracle — brings up Alloy agent + WireGuard peer
1. Deploy Protectli — brings up Alloy agent
1. Deploy RPis (when they come online) — brings up Alloy agents

### Verification

After deploying NAS:

- Visit `https://grafana.diekvoss.net`, log in with admin credentials
- Check Prometheus targets at `http://10.1.0.3:9090/targets` — NAS should show as UP

After deploying Router:

- Router should appear as UP in Prometheus targets
- Check Loki logs in Grafana → Explore → Loki datasource

After deploying Oracle:

- Verify WireGuard tunnel: `ping 10.100.0.2` from Router
- Oracle should appear in Prometheus targets

### Future Work (not in this plan)

- Grafana alerting rules (disk, CPU, service down)
- Service-specific dashboards (Jellyfin, Nextcloud, Immich, PostgreSQL)
- Kea DHCP exporter on Router
- Minecraft exporter on Oracle
- Grafana provisioned dashboards (Node Exporter Full, Loki explorer)

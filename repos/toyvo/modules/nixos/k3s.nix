{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.k3s;
in
{
  options.nixcfg.k3s = {
    enable = lib.mkEnableOption "k3s Kubernetes distribution";

    role = lib.mkOption {
      type = lib.types.enum [
        "server"
        "agent"
      ];
      default = "server";
      description = "Whether k3s should run as a server or agent.";
    };

    clusterInit = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Initialize HA cluster with embedded etcd. Exactly one server (the first) sets this.";
    };

    serverAddr = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://10.1.0.3:6443";
      description = "The k3s server to join. Required on every server except the cluster-init one, and on all agents.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/k3s-token";
      description = "Path to file containing the shared cluster token (sops-managed, never plaintext in store).";
    };

    extraSANs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "10.1.0.3"
        "nas.diekvoss.net"
      ];
      description = "Extra TLS SANs for the API server cert, passed as --tls-san flags.";
    };

    disable = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # servicelb (klipper-lb) stays off: no LoadBalancer services, no :80/:443
      # binds on nodes — Caddy on the router owns the edge. NOTE: packaged
      # disable flags must be identical on ALL servers; a single server with
      # a component enabled deletes the shared Addon cluster-wide (observed
      # with traefik). Keep this default uniform; override per-host only to
      # disable MORE, never less.
      default = [
        "traefik"
        "servicelb"
      ];
      description = "Disable default k3s components (traefik stays off unless traefik.enable; router Caddy owns the edge).";
    };

    disableAgent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Only run the server (etcd/control-plane, no kubelet workloads). For quorum-only members like the router.";
    };

    firewallInterfaces = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      example = [ "br0" ];
      description = "Interfaces to open k3s ports on. Null opens globally (LAN hosts behind NAT); set on WAN-facing boxes like the router.";
    };

    traefik = {
      enable = lib.mkEnableOption "k3s Traefik ingress (NodePort service with pinned nodePorts)";

      httpNodePort = lib.mkOption {
        type = lib.types.port;
        default = 30080;
        description = "Pinned NodePort for Traefik web (what Caddy forwards to).";
      };

      httpsNodePort = lib.mkOption {
        type = lib.types.port;
        default = 30443;
        description = "Pinned NodePort for Traefik websecure.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # NFS client tooling (mount.nfs) for node-level mounts and debugging.
    # The csi-driver-nfs containerizes its own mount helper, so this is
    # not on the k8s data path — but nodes need it for manual mounts.
    environment.systemPackages = [ pkgs.nfs-utils ];
    assertions = [
      {
        assertion = cfg.role == "server" || cfg.serverAddr != null;
        message = "nixcfg.k3s: agents must set serverAddr.";
      }
      {
        assertion = cfg.tokenFile != null;
        message = "nixcfg.k3s: tokenFile is required (sops-managed k3s-token); without it joins silently break.";
      }
      {
        assertion = cfg.clusterInit -> (cfg.role == "server" && cfg.serverAddr == null);
        message = "nixcfg.k3s: clusterInit is only valid on the first server (no serverAddr).";
      }
      {
        assertion = cfg.role == "server" && cfg.serverAddr == null -> cfg.clusterInit;
        message = "nixcfg.k3s: a server without serverAddr must be the cluster-init server.";
      }
      {
        assertion = cfg.disableAgent -> cfg.role == "server";
        message = "nixcfg.k3s: disableAgent only makes sense for a server.";
      }
    ];

    # Pod DNS: kubelet builds pod resolv.conf from --resolv-conf, and the
    # host file carries LAN search domains (diekvoss.*) whose router wildcard
    # answers at any depth. With ndots:5 every external hostname with <5
    # dots resolved to 10.1.0.1 inside pods (observed 2026-10-26: alert-80
    # TLS failures for ALL pod egress, incl. FlareSolverr + indexer tests).
    # A search-less copy keeps cluster.local expansion and lets bare
    # external names resolve correctly. Applies to every kubelet (servers +
    # agent); CoreDNS upstream is unchanged (same nameservers).
    environment.etc."rancher/k3s/resolv.conf".text = ''
      nameserver 10.1.0.1
      nameserver fdcd:2022:1118::1
    '';

    services.k3s = {
      enable = true;
      inherit (cfg)
        role
        clusterInit
        disableAgent
        tokenFile
        ;
      # traefik.enable removes only "traefik" from the disable list so any
      # other entries (e.g. servicelb) are still honored. Agents never get
      # --disable at all: `k3s agent` has no such flag and dies on it
      # (observed 2026-10-26: "flag provided but not defined: -disable").
      # Packaged charts are a server concern; agents ignore manifests anyway.
      disable = lib.mkIf (cfg.role == "server") (
        if cfg.traefik.enable then builtins.filter (x: x != "traefik") cfg.disable else cfg.disable
      );
      serverAddr = lib.mkIf (cfg.serverAddr != null) cfg.serverAddr;
      extraFlags = map (san: "--tls-san=${san}") cfg.extraSANs ++ [
        "--resolv-conf=/etc/rancher/k3s/resolv.conf"
      ];
      manifests = lib.mkIf cfg.traefik.enable {
        "traefik-config.yaml".content = {
          apiVersion = "helm.cattle.io/v1";
          kind = "HelmChartConfig";
          metadata = {
            name = "traefik";
            namespace = "kube-system";
          };
          spec.valuesContent = ''
            service:
              type: NodePort
            ports:
              web:
                nodePort: ${toString cfg.traefik.httpNodePort}
              websecure:
                nodePort: ${toString cfg.traefik.httpsNodePort}
          '';
        };
      };
    };

    # Ruling: opened globally by default — LAN hosts sit behind the router
    # NAT, interface names differ per host, and 6443 is token-gated.
    # 2379-2380 are the etcd client/peer ports: required on every server for
    # HA joins (the joiner syncs from the leader over 2380 in both directions).
    # WAN-facing boxes (router) must set firewallInterfaces instead.
    networking.firewall =
      let
        k3sTCP = [
          6443
          10250
          2379
          2380
        ];
        k3sUDP = [
          8472
          51820
          51821
        ];
      in
      if cfg.firewallInterfaces == null then
        {
          allowedTCPPorts = k3sTCP;
          allowedUDPPorts = k3sUDP;
        }
      else
        {
          interfaces = lib.genAttrs cfg.firewallInterfaces (_: {
            allowedTCPPorts = k3sTCP;
            allowedUDPPorts = k3sUDP;
          });
        };
  };
}

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
      # binds on nodes — the Traefik DaemonSet pinned to the router owns the edge. NOTE: packaged
      # disable flags must be identical on ALL servers; a single server with
      # a component enabled deletes the shared Addon cluster-wide (observed
      # with traefik). Keep this default uniform; override per-host only to
      # disable MORE, never less.
      default = [
        "traefik"
        "servicelb"
      ];
      description = "Disable default k3s components (traefik stays off unless traefik.enable).";
    };

    disableAgent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Only run the server (etcd/control-plane, no kubelet workloads). For quorum-only members like the router.";
    };

    nodeTaints = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "dedicated=edge:NoSchedule" ];
      description = "Extra --node-taint= flags for k3s servers.";
    };

    nodeIP = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "10.1.0.1";
      description = "Pin --node-ip/--advertise-address (multi-homed hosts only; the router's WAN IP churns and wedges etcd membership).";
    };

    firewallInterfaces = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      example = [ "br0" ];
      description = "Interfaces to open k3s ports on. Null opens globally (LAN hosts behind NAT); set on WAN-facing boxes like the router.";
    };

    traefik = {
      enable = lib.mkEnableOption "k3s Traefik ingress (NodePort service with pinned nodePorts)";

      tcpEntrypoints = lib.mkOption {
        type = lib.types.attrsOf lib.types.port;
        default = { };
        example = {
          netbird = 9443;
        };
        description = "Extra TCP entrypoints (e.g. NetBird); empty until its port map is known.";
      };

      httpNodePort = lib.mkOption {
        type = lib.types.port;
        default = 30080;
        description = "Pinned NodePort for Traefik web (legacy now that the edge binds :80 directly via hostNetwork).";
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

    # wg-quick inside pods hard-requires src_valid_mark for its fwmark
    # policy routing; net.ipv4.conf.all.* is host-global, so no pod can
    # set it. Harmless host-wide (standard for route-based WireGuard).
    boot.kernel.sysctl."net.ipv4.conf.all.src_valid_mark" = 1;

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
      extraFlags =
        map (san: "--tls-san=${san}") cfg.extraSANs
        ++ [
          "--resolv-conf=/etc/rancher/k3s/resolv.conf"
        ]
        ++ map (t: "--node-taint=${t}") cfg.nodeTaints
        ++ lib.optional (cfg.nodeIP != null) "--node-ip=${cfg.nodeIP}"
        ++ lib.optional (cfg.nodeIP != null) "--advertise-address=${cfg.nodeIP}";
      manifests = lib.mkIf cfg.traefik.enable {
        "traefik-config.yaml".content = {
          apiVersion = "helm.cattle.io/v1";
          kind = "HelmChartConfig";
          metadata = {
            name = "traefik";
            namespace = "kube-system";
          };
          spec.valuesContent = ''
            # Service (NodePort) is recreated by helm when missing; host ports are the edge.
            deployment:
              kind: DaemonSet
            updateStrategy:
              type: RollingUpdate
              rollingUpdate:
                maxUnavailable: 1
                maxSurge: 0
            hostNetwork: true
            nodeSelector:
              kubernetes.io/hostname: router
            tolerations:
              - key: dedicated
                operator: Equal
                value: edge
                effect: NoSchedule
            accesslog: true
            # Non-root + NET_BIND_SERVICE does not work on this k3s/containerd:
            # granted caps stay in the bounding set only (CapEff 0 for uid != 0),
            # so the listener bind fails with EACCES. Run as root instead, with
            # the container capability set still restricted to NET_BIND_SERVICE.
            podSecurityContext:
              runAsUser: 0
              runAsGroup: 0
              runAsNonRoot: false
              seccompProfile:
                type: RuntimeDefault
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                  - ALL
                add:
                  - NET_BIND_SERVICE
              readOnlyRootFilesystem: true
            metrics:
              prometheus:
                entryPoint: metrics
            additionalArguments:
              - --entrypoints.metrics.address=127.0.0.1:8082
            service:
              # Chart 40.x renders service.spec verbatim and ignores service.type;
              # k3s packaged defaults set spec.type=LoadBalancer, so override it here.
              spec:
                type: NodePort
            ports:
              web:
                port: 80
                nodePort: ${toString cfg.traefik.httpNodePort}
                redirectTo: websecure
              websecure:
                port: 443
                nodePort: ${toString cfg.traefik.httpsNodePort}
              metrics:
                port: 8082
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: port: ''
                ${name}:
                  port: ${toString port}
                  expose: false'') cfg.traefik.tcpEntrypoints
            )}
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

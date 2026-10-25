{ config, lib, ... }:
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
      default = [ "traefik" ];
      description = "Disable default k3s components (traefik stays off; router Caddy owns the edge).";
    };
  };

  config = lib.mkIf cfg.enable {
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
    ];

    services.k3s = {
      enable = true;
      inherit (cfg)
        role
        clusterInit
        disable
        tokenFile
        ;
      serverAddr = lib.mkIf (cfg.serverAddr != null) cfg.serverAddr;
      extraFlags = map (san: "--tls-san=${san}") cfg.extraSANs;
    };

    # Ruling: opened globally, not interface-scoped — both hosts sit behind
    # the router NAT, interface names differ per host, and 6443 is token-gated.
    networking.firewall = {
      allowedTCPPorts = [
        6443
        10250
      ];
      allowedUDPPorts = [
        8472
        51820
        51821
      ];
    };
  };
}

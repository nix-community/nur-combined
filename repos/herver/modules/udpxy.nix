{ config, lib, pkgs, ... }:

let
  cfg = config.services.udpxy;

  # Assemble the udpxy command line from the typed options plus any escape-hatch
  # extra arguments. -T keeps udpxy in the foreground so systemd can supervise it.
  # null-valued flags are dropped by toGNUCommandLine.
  argv = lib.cli.toGNUCommandLine { } {
    T = true;
    v = cfg.verbose;
    S = cfg.statistics;
    a = cfg.bindAddress;
    p = cfg.port;
    m = cfg.multicastInterface;
    c = cfg.maxClients;
    B = cfg.bufferSize;
    n = cfg.niceIncrement;
  } ++ cfg.extraArgs;
in
{
  options.services.udpxy = {
    enable = lib.mkEnableOption "udpxy multicast-to-HTTP relay daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/udpxy { };
      defaultText = lib.literalExpression "pkgs.udpxy";
      description = "The udpxy package to use.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "IPv4 address or interface to listen on (udpxy -a).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4022;
      description = "TCP port to listen for HTTP requests on (udpxy -p).";
    };

    multicastInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "eth0";
      description = "IPv4 address or interface of the multicast source (udpxy -m).";
    };

    maxClients = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = "Maximum number of simultaneous clients to serve (udpxy -c).";
    };

    bufferSize = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "256Kb";
      description = "Buffer size for inbound multicast data, e.g. \"65536\", \"32Kb\", \"1Mb\" (udpxy -B).";
    };

    niceIncrement = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "nice value increment for the udpxy process (udpxy -n).";
    };

    verbose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable verbose output (udpxy -v).";
    };

    statistics = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable per-client statistics (udpxy -S).";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open {option}`services.udpxy.port` in the firewall.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "-M" "30" ];
      description = "Extra command-line arguments passed verbatim to udpxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.udpxy = {
      description = "udpxy multicast-to-HTTP relay daemon";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} ${lib.escapeShellArgs argv}";
        Restart = "on-failure";
        RestartSec = 5;

        # Run unprivileged under a transient user with a hardened sandbox.
        DynamicUser = true;
        AmbientCapabilities = [ "" ];
        CapabilityBoundingSet = [ "" ];
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallFilter = [ "@system-service" ];
        SystemCallArchitectures = "native";
      };
    };
  };
}

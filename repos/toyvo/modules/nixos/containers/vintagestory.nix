{
  config,
  lib,
  inputs,
  system,
  ...
}:
let
  cfg = config.containerPresets.vintagestory;
in
{
  options.containerPresets.vintagestory = {
    enable = lib.mkEnableOption "Vintage Story NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.3";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.4";
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host WAN-facing network interface for NAT masquerade and port forwarding";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/vintagestory";
      description = "Host path bind-mounted into the container at /var/lib/vintagestory";
    };

    vintagestoryUid = lib.mkOption {
      type = lib.types.int;
      default = 356;
      description = "Pinned UID for the vintagestory user (static, below 400; chown stateDir to this UID before first start)";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.nixcfg.packages.${system}.VintagestoryServer;
      defaultText = lib.literalExpression "inputs.nixcfg.packages.\${system}.VintagestoryServer";
      description = "Vintage Story server package";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 42420;
      description = "Vintage Story server listen port (TCP + UDP)";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-vintagestory" ];
      forwardPorts = [
        {
          sourcePort = cfg.port;
          proto = "tcp";
          destination = "${cfg.localAddress}:${toString cfg.port}";
        }
        {
          sourcePort = cfg.port;
          proto = "udp";
          destination = "${cfg.localAddress}:${toString cfg.port}";
        }
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    containers.vintagestory = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/var/lib/vintagestory" = {
          hostPath = cfg.stateDir;
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        {
          users.users.vintagestory = {
            uid = lib.mkForce cfg.vintagestoryUid;
            description = "Vintage Story server service user";
            home = "/var/lib/vintagestory";
            createHome = true;
            isSystemUser = true;
            group = "vintagestory";
          };
          users.groups.vintagestory = { };

          systemd.tmpfiles.rules = [
            "d /var/lib/vintagestory 0750 vintagestory vintagestory -"
          ];

          systemd.services.vintagestory = {
            description = "Vintage Story Server";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              ExecStart = "${cfg.package}/bin/VintagestoryServer --dataPath /var/lib/vintagestory";
              Restart = "always";
              RestartSec = "10s";
              User = "vintagestory";
              Group = "vintagestory";
              WorkingDirectory = "/var/lib/vintagestory";

              CapabilityBoundingSet = [ "" ];
              DeviceAllow = [ "" ];
              LockPersonality = true;
              NoNewPrivileges = true;
              PrivateDevices = true;
              PrivateTmp = true;
              PrivateUsers = true;
              ProtectClock = true;
              ProtectControlGroups = true;
              ProtectHome = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectProc = "invisible";
              ProtectSystem = "strict";
              ReadWritePaths = [ "/var/lib/vintagestory" ];
              RestrictAddressFamilies = [
                "AF_INET"
                "AF_INET6"
              ];
              RestrictNamespaces = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
              SystemCallArchitectures = "native";
              UMask = "0077";
            };
          };

          networking.firewall.allowedTCPPorts = [ cfg.port ];
          networking.firewall.allowedUDPPorts = [ cfg.port ];

          system.stateVersion = "26.05";
        };
    };
  };
}

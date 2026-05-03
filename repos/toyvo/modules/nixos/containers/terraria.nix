{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.containerPresets.terraria;
  ids = config.ids;
  tmuxCmd = "${pkgs.tmux}/bin/tmux -S /var/lib/terraria/terraria.sock";
in
{
  options.containerPresets.terraria = {
    enable = lib.mkEnableOption "Terraria (TShock) NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.5";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.1.6";
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host WAN-facing network interface for NAT masquerade and port forwarding";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/terraria";
      description = "Host path bind-mounted into the container at /var/lib/terraria";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.tshock;
      defaultText = lib.literalExpression "pkgs.tshock";
      description = "TShock (or vanilla terraria-server) package to use";
    };

    worldPath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/terraria/world.wld";
      description = "Path to the world file; auto-created if it does not exist";
    };

    autoCreatedWorldSize = lib.mkOption {
      type = lib.types.enum [
        "small"
        "medium"
        "large"
      ];
      default = "large";
      description = "Size of the auto-created world if worldPath does not exist";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Maximum number of players";
    };

    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Server password; null for no password";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
      description = "Terraria server listen port (TCP + UDP)";
    };

    restPort = lib.mkOption {
      type = lib.types.port;
      default = 7878;
      description = "TShock REST API port (proxied by Caddy on the host)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.monitoring.containerJournals = [ "terraria" ];
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-terraria" ];
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

    systemd.tmpfiles.rules = [
      "d /var/lib/nixos-containers/terraria/var/log/journal 0755 root systemd-journal -"
    ];

    containers.terraria = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/var/lib/terraria" = {
          hostPath = cfg.stateDir;
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        let
          worldSizeFlag =
            {
              small = "1";
              medium = "2";
              large = "3";
            }
            .${cfg.autoCreatedWorldSize};
          flags = lib.concatStringsSep " " (
            [
              "-port ${toString cfg.port}"
              "-maxplayers ${toString cfg.maxPlayers}"
              "-world ${cfg.worldPath}"
              "-autocreate ${worldSizeFlag}"
            ]
            ++ lib.optional (cfg.password != null) "-pass ${lib.escapeShellArg cfg.password}"
          );
          stopScript = pkgs.writeShellScript "terraria-stop" ''
            if ! [ -d "/proc/$1" ]; then exit 0; fi
            lastline=$(${tmuxCmd} capture-pane -p | grep . | tail -n1)
            if [[ "$lastline" =~ ^'Choose World' ]]; then
              ${tmuxCmd} kill-session
            else
              ${tmuxCmd} send-keys Enter exit Enter
            fi
            tail --pid="$1" -f /dev/null
          '';
        in
        {
          # The nixpkgs services.terraria module hardcodes pkgs.terraria-server in ExecStart
          # with no package override option, so we can't swap in TShock through it.
          # Instead the service is defined inline using TShock, which is aarch64-linux
          # compatible and free (unlike the vanilla server which is x86_64-only and unfree).
          #
          # TShock uses the registered nixpkgs UID/GID 253 (same as vanilla terraria-server)
          users.users.terraria = {
            description = "Terraria server service user";
            group = "terraria";
            home = "/var/lib/terraria";
            createHome = true;
            uid = ids.uids.terraria;
          };
          users.groups.terraria.gid = ids.gids.terraria;

          systemd.tmpfiles.rules = [
            "d /var/lib/terraria 0750 terraria terraria -"
            "d /var/lib/terraria/tshock 0750 terraria terraria -"
          ];

          systemd.services.terraria = {
            description = "Terraria Server (TShock)";
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];
            serviceConfig = {
              User = "terraria";
              Group = "terraria";
              Type = "forking";
              GuessMainPID = true;
              UMask = 7;
              WorkingDirectory = "/var/lib/terraria";
              ExecStart = "${tmuxCmd} new -d ${lib.getExe cfg.package} ${flags}";
              ExecStop = "${stopScript} $MAINPID";
            };
          };

          networking.firewall.allowedTCPPorts = [
            cfg.port
            cfg.restPort
          ];
          networking.firewall.allowedUDPPorts = [ cfg.port ];

          system.stateVersion = "26.05";
        };
    };
  };
}

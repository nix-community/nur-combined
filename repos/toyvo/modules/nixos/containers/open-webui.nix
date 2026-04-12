{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.containerPresets.open-webui;
in
{
  options.containerPresets.open-webui = {
    enable = lib.mkEnableOption "Open WebUI NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.13";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.14";
      description = "Container IP address";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/open-webui";
      description = "Host path bind-mounted into the container at /var/lib/open-webui";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.open-webui;
      defaultText = lib.literalExpression "pkgs.open-webui";
      description = "The open-webui package to use";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Open WebUI listen port";
    };

    ollamaBaseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "OLLAMA_BASE_URL environment variable; null uses Open WebUI's default";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables passed to Open WebUI";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Host path to an environment file bind-mounted into the container and passed to Open WebUI (useful for secrets)";
    };

    natInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Host WAN-facing interface for NAT masquerade; required when Open WebUI needs to reach LAN hosts outside the container network";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nat = lib.mkIf (cfg.natInterface != null) {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-open-webui" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/nixos-containers/open-webui/var/log/journal 0755 root systemd-journal -"
    ];

    containers.open-webui = {
      autoStart = true;
      extraFlags = [ "--link-journal=host" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/var/lib/open-webui" = {
          hostPath = cfg.stateDir;
          isReadOnly = false;
        };
      }
      // lib.optionalAttrs (cfg.environmentFile != null) {
        "/run/secrets/open-webui.env" = {
          hostPath = cfg.environmentFile;
          isReadOnly = true;
        };
      };

      config =
        { ... }:
        {
          services.open-webui = {
            enable = true;
            host = "0.0.0.0";
            inherit (cfg) port package;
            environment =
              cfg.environment
              // lib.optionalAttrs (cfg.ollamaBaseUrl != null) {
                OLLAMA_BASE_URL = cfg.ollamaBaseUrl;
              };
            environmentFile = lib.mkIf (cfg.environmentFile != null) "/run/secrets/open-webui.env";
          };

          # services.open-webui uses DynamicUser=true which conflicts with the
          # bind-mounted stateDir (systemd tries to migrate /var/lib/open-webui
          # to /var/lib/private/open-webui but the bind mount is in the way).
          # Use a static user instead.
          systemd.services.open-webui.serviceConfig = {
            DynamicUser = lib.mkForce false;
            User = lib.mkForce "open-webui";
            Group = lib.mkForce "open-webui";
          };

          users.users.open-webui = {
            uid = 357;
            isSystemUser = true;
            group = "open-webui";
          };
          users.groups.open-webui.gid = 357;

          systemd.tmpfiles.rules = [
            "d /var/lib/open-webui 0750 open-webui open-webui -"
          ];

          networking.firewall.allowedTCPPorts = [ cfg.port ];

          system.stateVersion = "26.05";
        };
    };
  };
}

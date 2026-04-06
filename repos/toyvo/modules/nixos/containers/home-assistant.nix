{
  config,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  cfg = config.containerPresets.home-assistant;
in
{
  options.containerPresets.home-assistant = {
    enable = lib.mkEnableOption "Home Assistant NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.7";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.8";
      description = "Container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.str;
      description = "Host LAN-facing network interface for NAT masquerade (home-assistant reaches external cloud services)";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/home-assistant";
      description = "Directory bind-mounted into the container at /var/lib/hass";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.home-assistant;
      defaultText = lib.literalExpression "pkgs.home-assistant";
      description = "home-assistant package. Use .override { extraComponents = [...]; extraPackages = ps: [...]; } to add integrations.";
    };

    haConfig = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Settings merged into the home-assistant config block (http and server_port are always set by the module)";
    };

    ports = {
      home-assistant = lib.mkOption {
        type = lib.types.port;
        default = homelab.home-assistant.services.home-assistant.port;
        description = "Home Assistant listen port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Container is named 'hass' to keep the veth interface name (ve-hass) within
    # Linux's 15-character IFNAMSIZ limit. 've-home-assistant' would be 17 chars.
    networking.nat = {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-hass" ];
    };

    systemd.nspawn.hass.execConfig.LinkJournal = "host";

    containers.hass = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/var/lib/hass" = {
          hostPath = cfg.stateDir;
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        {
          services.home-assistant = {
            enable = true;
            openFirewall = true;
            package = cfg.package;
            # http block is always injected so the port and proxy settings are
            # correct regardless of what the caller puts in haConfig.
            config = lib.recursiveUpdate {
              http = {
                use_x_forwarded_for = true;
                trusted_proxies = [ homelab.router.ip ];
                server_port = cfg.ports.home-assistant;
              };
            } cfg.haConfig;
          };

          system.stateVersion = "26.05";
        };
    };
  };
}

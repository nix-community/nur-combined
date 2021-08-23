{ lib, pkgs, config, ... }:

let
  cfg = config.services.vlmcsd;
in
{
  options.services.vlmcsd = {
    enable = lib.mkEnableOption "vlmcsd service";

    listen = {
      address = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = "Address to listen on";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 1688;
        description = "Port to listen on";
      };
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open ports in the firewall for vlmcsd";
    };

    disconnectClients = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disconnect clients after each request";
    };

    disconnectTimeout = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Disconnect client after <seconds> of inactivity";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.vlmcsd = {
      description = "vlmcsd service";

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.nur.repos.pborzenkov.vlmcsd}/bin/vlmcsd -e -D \
          -L ${cfg.listen.address}:${toString cfg.listen.port} \
          ${lib.optionalString (cfg.disconnectClients) "-d"} \
          -t ${toString cfg.disconnectTimeout}
        '';

        DynamicUser = true;
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ];
    };
  };
}

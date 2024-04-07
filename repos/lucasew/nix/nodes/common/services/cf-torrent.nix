{
  pkgs,
  self,
  lib,
  config,
  ...
}:
let
  cfg = config.services.cf-torrent;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    mkDefault
    ;
in
{
  options.services.cf-torrent = {
    enable = mkEnableOption "cf-torrent";
    package = mkOption {
      description = "Which cf-torrent package to use";
      default = pkgs.callPackage self.inputs.cf-torrent { };
      type = types.package;
    };
    port = mkOption {
      description = "Port for cf-torrent";
      default = config.networking.ports.cf-torrent.port;
      type = types.port;
    };
    shutdownTimeout = mkOption {
      description = "Time in ms to shutdown the service when inactive";
      default = 10 * 1000;
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    networking.ports.cf-torrent.enable = mkDefault true;
    # networking.ports.cf-torrent.port = mkDefault 49151;

    services.cf-torrent.port = mkDefault config.networking.ports.cf-torrent.port;

    services.nginx.virtualHosts."cf-torrent.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
    systemd.sockets.cf-torrent = {
      socketConfig = {
        ListenStream = cfg.port;
      };
      partOf = [ "cf-torrent.service" ];
      wantedBy = [
        "sockets.target"
        "multi-user.target"
      ];
    };
    systemd.services.cf-torrent = {
      inherit (cfg.package.meta) description;
      unitConfig = {
        After = [ "network.target" ];
      };
      environment = {
        INACTIVITY_TIMEOUT = toString cfg.shutdownTimeout;
      };
      script = ''
        exec ${cfg.package}/bin/*
      '';
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.phantomsocks;
  settingsFormat = pkgs.formats.json { };
  settingsFile = settingsFormat.generate "config.json" cfg.settings;
in
{

  options = {
    services.phantomsocks = {
      enable = mkEnableOption (lib.mdDoc "phantomsocks");

      settings = mkOption {
        default = { };
        type = types.submodule { freeformType = settingsFormat.type; };
      };

      package = mkPackageOptionMD pkgs "phantomsocks" { };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.phantomsocks = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "phantomsocks daemon";
      restartTriggers = [ settingsFile ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${lib.getExe' cfg.package "phantomsocks"} -c ${settingsFile} -log 1";
        CapabilityBoundingSet = [
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];
        AmbientCapabilities = [
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];

        Restart = "on-failure";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ oluceps ];
}

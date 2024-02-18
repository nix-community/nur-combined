{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.realm;
  settingsFormat = pkgs.formats.json { };
  settingsFile = settingsFormat.generate "config.json" cfg.settings;
in
{

  options = {
    services.realm = {
      enable = mkEnableOption (lib.mdDoc "realm");

      settings = mkOption {
        default = { };
        type = types.submodule {
          freeformType = settingsFormat.type;
        };
      };

      package = mkPackageOptionMD pkgs "realm" { };

    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.realm = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "realm daemon";
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} -c ${settingsFile}";
        AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" ];
        Restart = "on-failure";
      };
    };

  };

  meta.maintainers = with lib.maintainers; [ oluceps ];
}

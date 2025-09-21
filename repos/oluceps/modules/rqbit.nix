{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkEnableOption
    mkIf
    ;

  cfg = config.services.rqbit;
in
{
  options.services.rqbit = {
    enable = mkEnableOption "rqbit service";
    package = mkPackageOption pkgs "rqbit" { };
    location = mkOption {
      type = types.str;
    };
  };
  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    users = {
      users.rqbit = {
        group = "rqbit";
        home = "/var/lib/rqbit";
        isSystemUser = true;
      };

      groups = {
        rqbit = {
        };
      };
    };

    networking.firewall.allowedTCPPortRanges = [
      {
        from = 4240;
        to = 4260;
      }
    ];
    networking.firewall.allowedUDPPorts = [
      36741
    ];

    systemd.services.rqbit = {
      wantedBy = [ "multi-user.target" ];
      description = "download daemon";
      serviceConfig = {
        Type = "simple";
        User = "rqbit";
        Group = "rqbit";
        ExecStart = "${lib.getExe' cfg.package "rqbit"} --http-api-listen-addr [::]:3030 server start ${cfg.location}";
        Restart = "on-failure";
      };
    };
  };
}

{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.srs;
in
{
  options.services.srs = {
    enable = mkEnableOption "srs server";
    package = mkPackageOption pkgs "srs" { };
    config = mkOption {
      type = types.str;
      default = "";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.srs = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      preStart = ''
        mkdir -p /var/lib/srs
        cp -r ${cfg.package}/objs /var/lib/srs/
      '';

      serviceConfig = {
        Type = "forking";
        PIDFile = "/run/srs.pid";
        WorkingDirectory = "/var/lib/srs";
        ExecStart = "${cfg.package}/bin/srs -c ${pkgs.writeText "srs.conf" cfg.config}";
        StateDirectory = "srs";
        Restart = "always";
      };
    };
  };
}

{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.ktistec;
  inherit (lib) mkPackageOption mkEnableOption mkIf;
in
{
  options.services.ktistec = {
    enable = mkEnableOption "enable ktistec service";
    package = mkPackageOption pkgs "ktistec" { };
  };
  config = mkIf cfg.enable {
    systemd.services.ktistec = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "ktistec Daemon";
      preStart = ''
        rm /var/lib/ktistec/app
        ln -sfT ${cfg.package}/app /var/lib/ktistec/app
      '';

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "ktistec";
        WorkingDirectory = "/var/lib/ktistec/app";
        Environment = [ "KTISTEC_DB=/var/lib/ktistec/ktistec.db" ];
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
      };
    };
  };
}

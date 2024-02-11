{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.wopiserver;
  format = pkgs.formats.ini { };
  configFile = format.generate "wopiserver.conf" cfg.settings;
in
{
  options.services.wopiserver = {
    enable = mkEnableOption (mdDoc "WOPI application gateway");
    package = lib.mkPackageOption pkgs "wopiserver" { };
    settings = mkOption {
      type = format.type;
      default = {
        io.recoverypath = "/var/lib/wopi/recovery";
      };
      example = {
        general = {
          loghandler = "stream";
          logdest = "stdout";
        };
      };
      description = mdDoc ''
        wopiserver configuration.
        Refer to <https://github.com/cs3org/wopiserver/blob/master/wopiserver.conf>
        for details on supported values.
      '';
    };
  };
  config = mkIf cfg.enable {
    systemd.services.wopiserver = {
      description = "wopiserver";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ cfg.package ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStartPre = pkgs.writeShellScript "wopiserver-prestart" "ln -sf ${configFile} /etc/wopi/wopiserver.conf";
        ExecStart = "${cfg.package}/bin/wopiserver";
        DynamicUser = true;
        ConfigurationDirectory = "wopi";
        LogsDirectory = "wopi";
        StateDirectory = "wopi";
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sunloginclient;
  package =
    if cfg.uiScale == null then
      cfg.package
    else
      cfg.package.override {
        inherit (cfg) uiScale;
      };
in
{
  options.services.sunloginclient = {
    enable = lib.mkEnableOption "Sunlogin remote control";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/sunloginclient { };
      defaultText = lib.literalExpression "pkgs.nur.repos.so1ve.sunloginclient";
      description = "Sunlogin package to use for the desktop client and service.";
    };
    uiScale = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      example = 2;
      description = ''
        Desktop UI scale factor: 1 is 100%, 2 is 200%, and so on.
        The GTK/Flutter client supports integer factors only. Leave null
        to keep automatic scaling. This does not affect the system daemon.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];
    users.groups.sunloginclient = { };

    systemd.services.sunloginclient = {
      description = "Sunlogin remote control service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        touch /var/lib/sunloginclient/orayconfig.conf
        touch /var/lib/sunloginclient/sys_config.conf
        chmod 0640 /var/lib/sunloginclient/orayconfig.conf /var/lib/sunloginclient/sys_config.conf
      '';
      serviceConfig = {
        Type = "simple";
        Group = "sunloginclient";
        ExecStart = "${lib.getExe package} --service";
        Restart = "always";
        RestartSec = 5;
        StateDirectory = "sunloginclient";
        StateDirectoryMode = "0750";
        LogsDirectory = "awesun";
        LogsDirectoryMode = "2770";
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sunloginclient;
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
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
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
        ExecStart = "${lib.getExe cfg.package} --service";
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

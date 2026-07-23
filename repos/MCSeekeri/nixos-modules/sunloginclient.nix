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
    enable = lib.mkEnableOption "Sunlogin remote-control daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/sunloginclient { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/sunloginclient { }";
      description = "The Sunlogin package to run.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sunloginclient = {
      description = "Sunlogin remote-control daemon";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/opt/awesun/bin/awesun_daemon -m server -name awesun";
        BindReadOnlyPaths = "${cfg.package}/opt/awesun:/usr/local/awesun";
        Restart = "on-failure";
        RestartSec = 5;
        KillMode = "control-group";
        LogsDirectory = "awesun";
      };
    };
  };
}

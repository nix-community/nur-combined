# Add Qingjian to Fcitx5 and start its server with the graphical user session.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.qingjian;
in
{
  options.services.qingjian = {
    enable = lib.mkEnableOption "the Qingjian Fcitx5 input method";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/qingjian { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/qingjian { }";
      description = "Qingjian package containing the server, Fcitx5 addon, and product data.";
    };
  };
  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = [ cfg.package ];
    };
    environment.systemPackages = [ cfg.package ];
    systemd.user.services.qingjian = {
      description = "Qingjian input method server";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session-pre.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/qingjian-linux-server";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}

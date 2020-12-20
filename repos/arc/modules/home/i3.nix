{ config, pkgs, lib, ... }: let
  sessionStart = pkgs.writeShellScriptBin "i3-session" ''
    set -eu
    ${config.systemd.package}/bin/systemctl --user set-environment I3SOCK=$(${config.xsession.windowManager.i3.package}/bin/i3 --get-socketpath)
    ${config.systemd.package}/bin/systemctl --user start graphical-session-i3.target
  '';
in {
  config = lib.mkIf config.xsession.windowManager.i3.enable {
    xsession.windowManager.i3.config.startup = [
      { command = "${sessionStart}/bin/i3-session"; notification = false; }
    ];
    systemd.user.targets.graphical-session-i3 = {
      Unit = {
        Description = "i3 X session";
        BindsTo = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };
    };
  };
}

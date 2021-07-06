{ config, pkgs, lib, ... }: with lib; let
  sessionStart = pkgs.writeShellScript "i3-session" ''
    set -eu
    ${config.systemd.package or pkgs.systemd}/bin/systemctl --user set-environment I3SOCK=$(${config.xsession.windowManager.i3.package}/bin/i3 --get-socketpath)
    ${config.systemd.package or pkgs.systemd}/bin/systemctl --user start i3-session.target
  '';
  inherit (config.xsession.windowManager.i3) enable;
in {
  config = mkIf enable {
    xsession.windowManager.i3.config.startup = [
      { command = "${sessionStart}"; notification = false; }
    ];
    systemd.user.targets.i3-session = {
      Unit = {
        Description = "i3 X session";
        BindsTo = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };
    };
    systemd.user.services.polybar = mkIf (config.services.polybar.enable && enable) {
      Unit.After = [ "i3-session.target" ];
      Install.WantedBy = mkForce [ "i3-session.target" ];
    };
  };
}

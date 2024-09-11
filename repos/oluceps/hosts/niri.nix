{
  user,
  lib,
  pkgs,
  ...
}:
{
  programs.niri.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --remember --time --cmd ${pkgs.writeShellScript "wm-startup" ''
          niri-session
        ''}";
        inherit user;
      };
      default_session = initial_session;
    };
  };
  systemd.user.services.swaybg = {
    wantedBy = [ "niri.service" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.swaybg} -i %h/Pictures/109066252_p0.jpg -m fill";
      Restart = "on-failure";
    };
  };
  systemd.user.services.waybar = {
    wantedBy = [ "niri.service" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    path = [ (lib.makeBinPath [ pkgs.pw-volume ]) ];
    serviceConfig = {
      ExecStart = lib.getExe pkgs.waybar;
      Restart = "on-failure";
    };
  };
}

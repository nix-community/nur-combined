{
  user,
  lib,
  pkgs,
  ...
}:
{
  programs.niri = {
    # aligh waybar rpc etc
    package = pkgs.niri;
    enable = true;
  };
  programs.hyprlock.enable = true;
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
  systemd.user = {
    services = {
      swaybg = {
        wantedBy = [ "niri.service" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.swaybg} -i %h/Pictures/109066252_p0.jpg -m fill";
          Restart = "on-failure";
        };
      };
      waybar = {
        wantedBy = [ "niri.service" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        # path = [ (lib.makeBinPath [ pkgs.niri ]) ];
        serviceConfig = {
          ExecStart = lib.getExe pkgs.waybar;
          Restart = "on-failure";
        };
      };
      xwayland-satellite = {
        wantedBy = [ "niri.service" ];
        after = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = lib.getExe pkgs.xwayland-satellite;
          Restart = "on-failure";
        };
      };
    };
  };
}

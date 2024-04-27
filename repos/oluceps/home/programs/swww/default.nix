{
  pkgs,
  lib,
  config,
  user,
  ...
}:
let
  cfg = config.programs.swww;
in
{
  options.programs.swww = {
    enable = lib.options.mkEnableOption "swww";
  };
  config = lib.mkIf cfg.enable {

    systemd.user.services.swww-daemon = {
      Unit = {
        Requires = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "notify";
        ExecStart = "${pkgs.swww}/bin/swww-daemon";
        Restart = "on-failure";
        Environment = [
          "WAYLAND_DISPLAY=wayland-1"
          "XDG_RUNTIME_DIR=/run/user/1000"
          "PATH=${
            lib.makeBinPath [
              pkgs.procps
              pkgs.swww
            ]
          }"
        ];
      };
      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

    systemd.user.services.swww = {
      Unit = {
        PartOf = [ "graphical-session.target" ];
        After = [
          "graphical-session.target"
          "swww-daemon.service"
        ];
        Requires = [ "swww-daemon.service" ];
      };
      Service = {
        Restart = "on-failure";
        Type = "oneshot";
        Environment = [
          "XDG_CACHE_HOME=/home/${user}/.cache"
          "WAYLAND_DISPLAY=wayland-1"
        ];
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
        ExecStart = ''
          ${pkgs.swww}/bin/swww img --resize=no -f Nearest ${
            pkgs.fetchurl {
              url = "https://s3.nyaw.xyz/misc/u6-fit.gif";
              sha256 = "17a3xjp91v4syj0rhxylwl9rbvfn73dk0f688hhsm8j0lipbg3r1";
            }
          }
        '';
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };
  };
}

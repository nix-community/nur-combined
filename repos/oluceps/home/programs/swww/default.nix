{
  pkgs,
  lib,
  user,
  config,
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
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.swww}/bin/swww-daemon";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };
    systemd.user.services.swww = {
      Unit = {
        PartOf = [ "graphical-session.target" ];
        Requires = [
          "swww-daemon.service"
          "graphical-session.target"
        ];
        After = [
          "graphical-session.target"
          "swww-daemon.service"
        ];
      };

      Service = {
        ExecStart = "${lib.getExe pkgs.swww} img --resize=fit ${
          pkgs.fetchurl {
            url = "https://s3.nyaw.xyz/misc/u6.gif";
            hash = "sha256-rlYUaXCdbPNO0yC1ytw2j/U8aMbpVKsRc3uwpClFCgM=";
          }
        }";
        Type = "oneshot";
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };
  };
}

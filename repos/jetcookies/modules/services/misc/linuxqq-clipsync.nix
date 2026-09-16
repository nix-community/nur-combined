{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.linuxqq-clipsync;
in
{
  options.services.linuxqq-clipsync = {
    enable = lib.mkEnableOption "linuxqq-clipsync, the X11 <-> Wayland clipboard sync daemon";

    package = lib.mkPackageOption pkgs [ "nur" "repos" "jetcookies" "linuxqq-clipsync" ] { };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.linuxqq-clipsync" pkgs lib.platforms.linux)
    ];

    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    systemd.user.services.linuxqq-clipsync = {
      Unit = {
        Description = "X11 <-> Wayland Clipboard Sync Daemon";
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "always";
        TimeoutStopSec = 3;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

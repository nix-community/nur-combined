{ pkgs, lib, config, ... }:
{
  config = lib.mkIf config.programs.gamemode.enable {
    # let's vulkanize it all until something breaks
    # environment.variables.MESA_LOADER_DRIVER_OVERRIDE = "zink";

    programs.gamescope.enable = true;

    programs.gamemode = {
      enableRenice = true;
      settings = {
        # docs: https://github.com/FeralInteractive/gamemode/blob/master/example/gamemode.ini
        general = {
          desiredgov = "performance";
          renice = 10;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
          script_timeout = 10;
        };
      };
    };
  };
}

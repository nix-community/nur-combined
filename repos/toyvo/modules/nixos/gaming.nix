{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.gaming;
in
{
  options.profiles.gaming.enable = lib.mkEnableOption "Enable various gaming programs";

  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
      gamemode.enable = true;
    };
    environment.systemPackages = with pkgs; [
      discord
      heroic
      lutris
      mangohud
      prismlauncher
      protonup-ng
      gale
      r2modman
      steam
      steamcmd
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          obs-gstreamer
          obs-vaapi
          obs-vkcapture
        ];
      })
    ];
    home-manager.sharedModules = [
      {
        home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATH = "~/.steam/root/compatibilitytools.d";
      }
    ];
  };
}

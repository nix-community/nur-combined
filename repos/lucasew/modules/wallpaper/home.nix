{lib, config, pkgs, ...}:
let
    globalConfig = import ../../globalConfig.nix;
in
with globalConfig;
with lib;
with builtins;
{
  options.wallpaper = {
    enable = mkEnableOption "enable wallpaper administration";
    wallpaperFile = mkOption {
      type = types.str;
      default = globalConfig.wallpaper;
      example = "/path/to/wallpaper/file.png";
      description = "file to setup as wallpaper";
    };
  };
  config = 
  let
    wallpaper = config.wallpaper.wallpaperFile;
  in
  mkIf
  (config.wallpaper.enable && wallpaper != "/dev/null") 
  {
    dconf.settings = {
        "org/gnome/desktop/background" = {
            picture-uri = "file:///${toString wallpaper}";
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = "file:///${toString wallpaper}";
          picture-options="zoom";
          primary-color="#ffffff";
          secondary-color="#000000";
        };
    };
    home.file.".background-image".source = wallpaper;
    home.file.".fehbg".text = ''
      ${pkgs.feh}/bin/feh --no-fehbg --bg-center '${toString wallpaper}'
    '';
  };
}

{...}:
let
    globalConfig = import <dotfiles/globalConfig.nix>;
in
with globalConfig;
{
    dconf.settings = {
        "org/gnome/desktop/background" = {
            picture-uri = "file:///${wallpaper}";
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = "file:///${wallpaper}";
          picture-options="zoom";
          primary-color="#ffffff";
          secondary-color="#000000";
        };
    };
    home.file.".background-image".source = globalConfig.wallpaper;
}

{ lib, ... }:

let
  inherit (builtins) readDir;
  inherit (lib) optionalAttrs;

  mainModule = {
    abszero = {
      profiles.hyprland.enable = true;
      themes = {
        base = {
          firefox.verticalTabs = true;
          nushell.enable = true;
        };
        catppuccin = {
          fcitx5.enable = true;
          foot.enable = true;
          hyprland.enable = true;
          hyprpaper.nixosLogo = true;
          pointerCursor.enable = true;
        };
      };
    };

    catppuccin.accent = "pink";

    manual.manpages.enable = false;

    wayland.windowManager.hyprland.settings.monitor = "eDP-1, preferred, auto, 1.25";

    programs.man.enable = false; # Speed up builds
  };
in

# No-op if _base.nix is hidden
optionalAttrs (readDir ./. ? "_base.nix") {
  imports = [ ../_options.nix ];

  homeConfigurations."weathercold@toshiba-mq04ubb400-22rbt03qt" = {
    system = "x86_64-linux";
    modules = [
      # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
      (import ./_base.nix { inherit lib; })
      mainModule
    ];
  };
}

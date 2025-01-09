{ lib, ... }:

let
  inherit (builtins) readDir;
  inherit (lib) optionalAttrs;

  mainModule = {
    abszero = {
      profiles.hyprland.enable = true;
      themes = {
        base = {
          fastfetch.enable = true;
          firefox.verticalTabs = true;
          # hyprland.dynamicCursors.enable = true;
          nushell.enable = true;
        };
        catppuccin = {
          fcitx5.enable = true;
          foot.enable = true;
          gtk.enable = true;
          hyprland.enable = true;
          hyprpaper.nixosLogo = true;
          cursors.enable = true;
        };
      };
    };

    catppuccin = {
      accent = "pink";
      gtk.icon.enable = true;
    };

    wayland.windowManager.hyprland.settings.monitor = "eDP-1, preferred, auto, 1.25";

    programs.man.enable = false; # Speed up builds

    manual.manpages.enable = false;
  };
in

# No-op if _base.nix is hidden
optionalAttrs (readDir ./. ? "_base.nix") {
  imports = [ ../_options.nix ];

  homeConfigurations."weathercold@nixos-disk" = {
    system = "x86_64-linux";
    modules = [
      # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
      (import ./_base.nix { inherit lib; })
      mainModule
    ];
  };
}

let
  inherit (builtins) readDir warn;

  mainModule = {
    abszero = {
      profiles.hyprland.enable = true;
      themes = {
        base = {
          fastfetch.enable = true;
          hyprland.dynamicCursors.enable = true;
          nushell.enable = true;
          starship.enable = true;
        };
        catppuccin = {
          cursors.enable = true;
          fcitx5.enable = true;
          ghostty.enable = true;
          gtk.enable = true;
          hyprland.enable = true;
          hyprpaper = {
            enable = true;
            wallpaper = "nixos-logo";
          };
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

{
  imports = [ ../_options.nix ];

  homeConfigurations."weathercold@nixos-disk" = {
    system = "x86_64-linux";
    modules = [
      # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
      (
        if (readDir ./. ? "_base.nix") then
          ./_base.nix
        else
          warn "_base.nix is hidden, home configuration is incomplete" { }
      )
      mainModule
    ];
  };
}

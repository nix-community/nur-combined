# WARN: no longer updated as of 2025-07-18
let
  inherit (builtins) readDir warn;

  modules = {
    main = {
      imports = [
        ({ config, lib, ... }: lib.mkIf (config.specialisation != { }) modules.hyprland-latte-pink)
      ];

      abszero.profiles.full.enable = true;

      specialisation.plasma6-latte-pink.configuration = modules.plasma6-latte-pink;
    };

    hyprland-latte-pink = {
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
    };

    plasma6-latte-pink = {
      abszero = {
        services.desktopManager.plasma6.enable = true;
        themes = {
          base = {
            fastfetch.enable = true;
            nushell.enable = true;
            starship.enable = true;
          };
          catppuccin = {
            ghostty.enable = true;
            gtk.enable = true;
            plasma.enable = true;
          };
          colloid.fcitx5.enable = true;
        };
      };

      catppuccin.accent = "pink";

      xdg.dataFile."home-manager/specialisation".text = "plasma6-latte-pink";

      gtk.catppuccin.icon.enable = true;
    };
  };
in

{
  imports = [ ../_options.nix ];

  homeConfigurations."weathercold@nixos-inspiron" = {
    system = "x86_64-linux";
    modules = [
      # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
      (
        if (readDir ./. ? "_base.nix") then
          ./_base.nix
        else
          warn "_base.nix is hidden, home configuration is incomplete" { }
      )
      modules.main
    ];
  };
}

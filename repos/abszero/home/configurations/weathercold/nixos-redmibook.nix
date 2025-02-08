let
  inherit (builtins) readDir warn;

  mainModule = {
    abszero = {
      profiles.hyprland.enable = true;

      services.darkman = {
        enable = true;
        lightSpecialisation = "catppuccin-latte-pink";
        darkSpecialisation = "catppuccin-macchiato-pink";
      };

      themes = {
        base = {
          fastfetch.enable = true;
          # hyprland.dynamicCursors.enable = true;
          nushell.enable = true;
        };
        catppuccin = {
          cursors.enable = true;
          fcitx5.enable = true;
          foot.enable = true;
          gtk.enable = true;
          hyprland.enable = true;
          hyprpaper.nixosLogo = true;
        };
      };
    };

    catppuccin = {
      accent = "pink";
      gtk.icon.enable = true;
    };

    specialisation = {
      catppuccin-latte-pink = { };
      catppuccin-macchiato-pink.configuration.abszero.themes.catppuccin.polarity = "dark";
    };
  };
in

{
  imports = [ ../_options.nix ];

  homeConfigurations."weathercold@nixos-redmibook" = {
    system = "x86_64-linux";
    modules = [
      # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
      (
        if (readDir ./. ? "_base.nix") then
          ./_base.nix
        else
          warn "_base.nix is hidden, configuration is incomplete" { }
      )
      mainModule
    ];
  };
}

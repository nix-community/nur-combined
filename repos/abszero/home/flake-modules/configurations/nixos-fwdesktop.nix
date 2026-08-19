{ lib, ... }:

let
  inherit (lib) singleton;

  mainModule = {
    abszero = {
      profiles.driftwm.enable = true;

      services.darkman = {
        enable = true;
        lightSpecialisation = "catppuccin-latte-pink";
        darkSpecialisation = "catppuccin-macchiato-pink";
      };

      programs.driftwm.settings.outputs = singleton {
        name = "DP-4";
        mode = "3840x2160@120";
        scale = 2;
        # variable-refresh-rate = true; # TODO: enable when supported
      };

      themes = {
        base = {
          fastfetch.enable = true;
          nushell.enable = true;
          starship.enable = true;
        };
        catppuccin = {
          cursors.enable = true;
          driftwm.enable = true;
          fcitx5.enable = true;
          ghostty.enable = true;
          gtk.enable = true;
        };
      };
    };

    catppuccin = {
      accent = "pink";
      gtk.icon.enable = true;
    };

    specialisation = {
      # Hint nh to autoswitch to the current specialisation
      catppuccin-latte-pink.configuration.xdg.dataFile."home-manager/specialisation".text =
        "catppuccin-latte-pink";
      catppuccin-macchiato-pink.configuration = {
        abszero.themes.catppuccin.polarity = "dark";
        xdg.dataFile."home-manager/specialisation".text = "catppuccin-macchiato-pink";
      };
    };
  };
in

{
  abszero.homeConfigurations."weathercold@nixos-fwdesktop" = {
    system = "x86_64-linux";
    modules = [
      # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
      mainModule
    ];
  };
}

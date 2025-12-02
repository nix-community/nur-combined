let
  inherit (builtins) readDir warn;

  mainModule = {
    abszero = {
      profiles.niri.enable = true;

      services.darkman = {
        enable = true;
        lightSpecialisation = "catppuccin-latte-pink";
        darkSpecialisation = "catppuccin-macchiato-pink";
      };

      themes = {
        base = {
          fastfetch.enable = true;
          nushell.enable = true;
          starship.enable = true;
        };
        catppuccin = {
          cursors.enable = true;
          fcitx5.enable = true;
          foot.enable = true;
          gtk.enable = true;
          hyprpaper = {
            enable = true;
            wallpaper = "xppen-chan";
          };
          niri.enable = true;
        };
      };
    };

    catppuccin = {
      accent = "pink";
      gtk.icon.enable = true;
    };

    programs.niri.settings.outputs.eDP-1 = {
      # scale = 1.25;
      variable-refresh-rate = true;
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
  imports = [ ../_options.nix ];

  homeConfigurations."weathercold@nixos-fwdesktop" = {
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

{ lib, ... }:

let
  inherit (lib) singleton;

  mainModule = { pkgs, ... }: {
    abszero = {
      profiles.driftwm.enable = true;

      programs.driftwm.settings.outputs = singleton {
        name = "eDP-1";
        scale = 1.25;
        # variable-refresh-rate = true; # TODO: enable when supported
      };

      themes = {
        base = {
          pointerCursor.enable = true;
          driftwm.enableCompactLayout = true;
          fastfetch.enable = true;
          ghostty.enable = true;
          nushell.enable = true;
          starship.enable = true;
        };
        colloid.gtk.enable = true;
        noctalia = {
          driftwm.enable = true;
          fcitx5.enable = true;
          gtk.enable = true;
          noctalia.enable = true;
        };
      };
    };

    home.pointerCursor = {
      name = "aris-cursors";
      package = pkgs.aris-cursors;
    };

    # There's no ALS on framework 12 :(
    services.wluma.enable = false;
  };
in

{
  abszero.homeConfigurations."weathercold@nixos-fwlaptop" = {
    system = "x86_64-linux";
    modules = [
      mainModule
    ];
  };
}

{ lib, ... }:

let
  inherit (lib) singleton;

  mainModule = { pkgs, ... }: {
    abszero = {
      profiles.driftwm.enable = true;

      programs.driftwm.settings.outputs = singleton {
        name = "DP-4";
        mode = "3840x2160@120";
        scale = 2;
        # variable-refresh-rate = true; # TODO: enable when supported
      };

      themes = {
        base = {
          pointerCursor.enable = true;
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
  };
in

{
  abszero.homeConfigurations."weathercold@nixos-fwdesktop" = {
    system = "x86_64-linux";
    modules = [
      mainModule
    ];
  };
}

# Example configuration
{ lib, ... }:

let
  inherit (lib) mkIf singleton;

  system = "x86_64-linux"; # System architecture
  username = "custom";
  hostName = "custom";
  homeDirectory = null; # Default is "/home/${username}"
  # For firefox, put your firefox profile name here.
  firefoxProfile = null; # Default is username
in

{
  abszero.homeConfigurations."${username}@${hostName}" = {
    inherit system;
    homeDirectory = mkIf (homeDirectory != null) homeDirectory;
    modules = singleton {
      abszero = {
        profiles = {
          base.enable = true;
          full.enable = true;
          driftwm.enable = true;
        };
        programs.firefox.profile = mkIf (firefoxProfile != null) firefoxProfile;
        themes.base = {
          fastfetch.enable = true;
          foot.enable = true;
          ghostty.enable = true;
          hyprland.dynamicCursors.enable = true;
          nushell.enable = true;
          starship.enable = true;
        };
      };

      specialisation = {
        colloid.configuration = {
          abszero.themes.colloid = {
            fcitx5.enable = true;
            firefox.enable = true;
            fonts.enable = true;
            gtk.enable = true;
            plasma6.enable = true;
          };
          # Hint nh to autoswitch to the current specialisation
          xdg.dataFile."home-manager/specialisation".text = "colloid";
        };

        catppuccin.configuration = {
          abszero.themes.catppuccin = {
            enable = true;
            cursors.enable = true;
            discord.enable = true;
            driftwm = {
              enable = true;
              enableCompactLayout = true;
            };
            fcitx5.enable = true;
            fonts.enable = true;
            foot.enable = true;
            ghostty.enable = true;
            gtk.enable = true;
            hyprland.enable = true;
            niri = {
              enable = true;
              enableCompactLayout = true;
            };
            plasma6.enable = true;
          };
          xdg.dataFile."home-manager/specialisation".text = "catppuccin";
        };
      };
    };
  };
}

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
  imports = [ ./_options.nix ];

  homeConfigurations."${username}@${hostName}" = {
    inherit system;
    homeDirectory = mkIf (homeDirectory != null) homeDirectory;
    modules = singleton {
      abszero = {
        profiles.buildConfig.enable = true;
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
          xdg.dataFile."home-manager/specialisation".text = "colloid";
        };

        catppuccin.configuration = {
          abszero.themes.catppuccin = {
            enable = true;
            cursors.enable = true;
            discord.enable = true;
            fcitx5.enable = true;
            fonts.enable = true;
            foot.enable = true;
            ghostty.enable = true;
            gtk.enable = true;
            hyprland.enable = true;
            hyprpaper = {
              enable = true;
              wallpaper = "nixos-logo";
            };
            plasma6.enable = true;
          };
          xdg.dataFile."home-manager/specialisation".text = "catppuccin";
        };
      };
    };
  };
}

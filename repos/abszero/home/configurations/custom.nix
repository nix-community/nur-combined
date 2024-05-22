{ self, lib, ... }:

let
  inherit (lib) optionalAttrs;

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
    modules = [
      self.homeModules.profiles-build-config
      {
        abszero = optionalAttrs (firefoxProfile != null)
          { programs.firefox.profile = firefoxProfile; };

        # You can have multiple specialisations, but only one can be default.
        specialisation = {
          colloid = {
            default = true;
            configuration.imports = with self.homeModules; [
              colloid-fcitx5
              colloid-firefox
              colloid-fonts
              colloid-gtk
              colloid-plasma
            ];
          };

          catppuccin.configuration.imports = with self.homeModules; [
            catppuccin-catppuccin
            catppuccin-discord
            catppuccin-fcitx5
            catppuccin-fonts
            catppuccin-foot
            catppuccin-kvantum
            catppuccin-plasma
            catppuccin-stylix
          ];
        };
      }
    ];
  } // optionalAttrs (homeDirectory != null) { inherit homeDirectory; };
}

{ inputs, lib, ... }:

let
  inherit (lib) mkDefault;
in

{
  imports = [ inputs.stylix.homeManagerModules.stylix ];

  stylix = {
    fonts.sizes = {
      applications = 14;
      desktop = 12;
      popups = 14;
      terminal = 14;
    };

    targets = {
      firefox.enable = mkDefault false;
      fish.enable = mkDefault false;
      gtk.enable = mkDefault false;
      kde.enable = mkDefault false;
      vscode.enable = mkDefault false;
    };
  };
}

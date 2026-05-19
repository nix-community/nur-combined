{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ./fonts.nix
  ];

  options.abszero.themes.catppuccin.sddm.enable =
    mkEnableOption "catppuccin sddm theme. Complementary to catppuccin/nix";

  config = mkIf cfg.sddm.enable {
    abszero.themes.catppuccin = {
      enable = true;
      fonts.enable = true;
    };
    catppuccin.sddm = {
      enable = true;
      font = "Open Sans";
      fontSize = "14";
    };
  };
}

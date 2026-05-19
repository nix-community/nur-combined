{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.plymouth.enable =
    mkEnableOption "catppuccin plymouth theme. Complementary to catppuccin/nix";

  config = mkIf cfg.plymouth.enable {
    abszero.themes.catppuccin.enable = true;
    catppuccin.plymouth.enable = true;
    boot.plymouth.logo = pkgs.emptyFile;
  };
}

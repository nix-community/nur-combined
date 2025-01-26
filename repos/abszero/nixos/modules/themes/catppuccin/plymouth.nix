{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
  ];

  options.abszero.themes.catppuccin.plymouth.enable =
    mkExternalEnableOption config "catppuccin plymouth theme. Complementary to catppuccin/nix";

  config = mkIf cfg.plymouth.enable {
    abszero.themes.catppuccin.enable = true;
    catppuccin.plymouth.enable = true;
    boot.plymouth.logo = pkgs.emptyFile;
  };
}

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
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.catppuccin.fonts.enable =
    mkExternalEnableOption config "fonts to use with catppuccin theme";

  config.environment.systemPackages = with pkgs; mkIf cfg.fonts.enable [ open-sans ];
}

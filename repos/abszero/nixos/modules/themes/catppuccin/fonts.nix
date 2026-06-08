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
  options.abszero.themes.catppuccin.fonts.enable =
    mkEnableOption "fonts to use with catppuccin theme";

  config = mkIf cfg.fonts.enable {
    fonts.packages = with pkgs; [
      open-sans
      iosevka-inconsolata
      nerd-fonts.departure-mono
    ];
    services.kmscon.config.font-name = "Iosevka Inconsolata, DepartureMono Nerd Font";
  };
}

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

  config = {
    services.kmscon.fonts = [
      {
        name = "Iosevka Inconsolata";
        package = pkgs.iosevka-inconsolata;
      }
      {
        name = "DepartureMono Nerd Font";
        package = pkgs.nerd-fonts.departure-mono;
      }
    ];
    environment.systemPackages = with pkgs; mkIf cfg.fonts.enable [ open-sans ];
  };
}

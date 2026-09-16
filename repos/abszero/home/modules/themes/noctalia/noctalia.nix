{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.noctalia.noctalia;
in

{
  imports = [ ./fonts.nix ];

  options.abszero.themes.noctalia.noctalia.enable = mkEnableOption "noctalia base theme";

  config = mkIf cfg.enable {
    abszero.themes.noctalia.fonts.enable = true;
    programs = {
      btop.settings.color_theme = "noctalia";
      ghostty.settings.theme = "noctalia";
      helix.settings.theme = "noctalia";
    };
  };
}

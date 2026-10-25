{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.noctalia.driftwm;
in

{
  imports = [
    ../base/driftwm.nix
    ./fonts.nix
  ];

  options.abszero.themes.noctalia.driftwm.enable = mkEnableOption "noctalia driftwm theme";

  config = mkIf cfg.enable {
    abszero.themes = {
      base.driftwm.enable = true;
      noctalia.fonts.enable = true;
    };
    wayland.windowManager.driftwm.settings.decorations = {
      font = "Maple Mono NF CN";
      font_size = 14;
    };
  };
}

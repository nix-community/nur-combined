{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.noctalia.fonts;
in

{
  options.abszero.themes.noctalia.fonts.enable = mkEnableOption "fonts to use with noctalia theme";

  config = mkIf cfg.enable {
    fonts.packages = with pkgs; [
      maple-mono.NF-CN
      iosevka-inconsolata
    ];
    services.kmscon.config.font-name = "Iosevka Inconsolata, Maple Mono NF CN";
  };
}

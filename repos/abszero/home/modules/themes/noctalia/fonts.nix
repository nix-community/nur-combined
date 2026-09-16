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
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Maple Mono NF CN"
          "Noto Sans CJK"
        ];
        serif = [ "Roboto Serif" ];
        monospace = [
          "Iosevka Inconsolata"
          "Ligconsolata"
          "Fira Code"
        ];
        emoji = [ "Twemoji" ];
      };
    };

    home.packages = with pkgs; [
      maple-mono.NF-CN # TODO: custom build when supported
      noto-fonts-cjk-sans
      roboto-serif
      fira-code
      inconsolata
      iosevka-inconsolata
      cattie
      twitter-color-emoji
    ];

    programs.ghostty.settings = {
      font-family = "Iosevka Inconsolata";
      font-size = 13;
    };
  };
}

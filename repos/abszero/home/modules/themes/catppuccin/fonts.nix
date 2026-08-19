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
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Maple Mono NF CN"
          "Noto Sans CJK"
        ];
        serif = [ "Iosevka Etoile" ];
        monospace = [
          "Iosevka Inconsolata"
          "Ligconsolata"
          "Fira Code"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    home.packages = with pkgs; [
      maple-mono.NF-CN # TODO: custom build when supported
      noto-fonts-cjk-sans
      (iosevka-bin.override { variant = "Etoile"; })
      fira-code
      inconsolata
      iosevka-inconsolata
    ];
  };
}

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

  config = mkIf cfg.fonts.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Open Sans"
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
      open-sans
      noto-fonts-cjk-sans
      (iosevka-bin.override { variant = "Etoile"; })
      fira-code
      inconsolata
      iosevka-inconsolata
      nerd-fonts.departure-mono
    ];
  };
}

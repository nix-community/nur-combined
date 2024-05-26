{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    open-sans
    noto-fonts-cjk-sans
    fira-code
    inconsolata
    (iosevka-bin.override { variant = "Etoile"; })
    (iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}

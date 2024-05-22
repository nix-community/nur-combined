{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    open-sans
    noto-fonts-cjk-sans
    inconsolata-nerdfont
    (iosevka-bin.override { variant = "Etoile"; })
    (iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
  ];
}

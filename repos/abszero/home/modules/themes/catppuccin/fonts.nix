{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    inconsolata-nerdfont
    noto-fonts-cjk-sans
  ];
}

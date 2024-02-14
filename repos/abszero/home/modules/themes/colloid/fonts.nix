{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    inconsolata-nerdfont
    iosevka-bin
    noto-fonts-cjk-sans
  ];

  gtk.font = {
    package = pkgs.open-sans;
    name = "Open Sans";
    size = 14;
  };
}

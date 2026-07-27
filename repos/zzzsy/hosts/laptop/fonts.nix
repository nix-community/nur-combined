{ pkgs, lib, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
      maple-mono.truetype-autohint
      wqy_zenhei
      my.fonts.lxgw-wenkai-screen
      my.fonts.plangothic
      my.fonts.my-fonts
      my.fonts.iosevka-zt
    ];

    fontconfig = {
      subpixel.rgba = "none";
      antialias = true;
      hinting.enable = false;
      defaultFonts = lib.mkForce {
        serif = [
          "Noto Serif"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
        ];
        monospace = [
          "Iosevka ZT Extended"
          "Noto Sans Mono CJK SC"
          "Symbols Nerd Font"
          "Maple Mono"
        ];
        sansSerif = [
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK JP"
        ];
        emoji = [
          "noto-fonts-emoji"
        ];
      };
    };
  };
}

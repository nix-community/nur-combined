{ pkgs, ... }:
{
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      maple-mono
      wqy_zenhei
      my.lxgw-wenkai-screen
      my.plangothic
      my.my-fonts
      my.iosevka-zt
      my.these-fonts
    ];
    fontconfig = {
      localConf = builtins.readFile (./fontconfig.conf);
    };
  };
}

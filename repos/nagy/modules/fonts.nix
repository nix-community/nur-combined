{ config, pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = config.services.xserver.enable;
      defaultFonts = {
        monospace = [ "Iosevka Comfy" ];
        #   sansSerif = [ "" ];
        #   serif = [ "" ];
      };

      # these revert the config from `fonts.optimizeForVeryHighDPI`.
      antialias = true;
      hinting.enable = true;
      subpixel.lcdfilter = "default";
      subpixel.rgba = "rgb";
      includeUserConf = false;
    };
    enableDefaultPackages = true;
    packages = [
      pkgs.iosevka-comfy.comfy
      pkgs.etBook # EtBembo https://edwardtufte.github.io/et-book/
      pkgs.noto-fonts
      pkgs.noto-fonts-monochrome-emoji
      pkgs.nerd-fonts.symbols-only
    ];
  };
}

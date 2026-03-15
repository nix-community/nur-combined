{
  config,
  pkgs,
  ...
}:

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
      # This local config prevents these two characters from being sourced from Noto Serif Display:
      # Ŧ  LATIN CAPITAL LETTER T WITH STROKE
      # ŧ  LATIN SMALL LETTER T WITH STROKE
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <selectfont>
            <rejectfont>
              <pattern>
                <patelt name="family">
                  <string>Noto Serif Display</string>
                </patelt>
              </pattern>
            </rejectfont>
          </selectfont>
        </fontconfig>
      '';
    };
    enableDefaultPackages = true;
    packages = [
      pkgs.iosevka-comfy.comfy
      pkgs.et-book # EtBembo https://edwardtufte.github.io/et-book/
      pkgs.noto-fonts
      pkgs.noto-fonts-monochrome-emoji
      pkgs.nerd-fonts.symbols-only
    ];
  };
}

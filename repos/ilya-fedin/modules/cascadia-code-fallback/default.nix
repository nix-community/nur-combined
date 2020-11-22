{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.fonts.fontconfig.cascadiaCode;

  preferConf = pkgs.writeText "fc-30-metric-compatible-fonts.conf" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
        <!-- Cascadia Code contains only latin letters, map a list of fonts to it -->
        <match>
            <test name="family"><string>Cascadia Code</string></test>
            <edit name="family" mode="assign" binding="strong">
                <string>Cascadia Code</string>
                <string>${cfg.fallbackFont}</string>
            </edit>
        </match>
    </fontconfig>
  '';

  confPkg = pkgs.runCommand "cascadia-code-fallback-conf" {
    preferLocalBuild = true;
  } ''
    support_folder=$out/etc/fonts/conf.d
    mkdir -p $support_folder

    # 30-cascadia-code-fallback.conf
    ln -s ${preferConf}       $support_folder/30-cascadia-code-fallback.conf
  '';
in {
  options = {
    fonts.fontconfig.cascadiaCode = {
      enableFallback = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Make a predicable fallback for Cascadia Code.
        '';
      };

      fallbackFont = mkOption {
        type = types.str;
        default = "Fira Code";
        internal = true;
        description = ''
          Name of the font to fallback to.
        '';
      };

      fallbackPackage = mkOption {
        type = types.path;
        default = pkgs.fira-code;
        internal = true;
        description = ''
          Package of the font to fallback to.
        '';
      };
    };
  };

  config = mkIf cfg.enableFallback {
    fonts.fonts = [
      pkgs.cascadia-code
      cfg.fallbackPackage
    ];
    fonts.fontconfig.confPackages = [ confPkg ];
  };
}

{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.fonts.fontconfig;

  preferConf = pkgs.writeText "fc-30-metric-compatible-fonts.conf" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
    
    <!-- Map specific families to CrOS ones -->
    <match>
        <test name="family"><string>Arial</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Arimo</string>
        </edit>
    </match>
    <match>
        <test name="family"><string>Helvetica</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Arimo</string>
        </edit>
    </match>
    <match> <!-- NOT metric-compatible! -->
        <test name="family"><string>Verdana</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Arimo</string>
        </edit>
    </match>
    <match> <!-- NOT metric-compatible! -->
        <test name="family"><string>Tahoma</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Arimo</string>
        </edit>
    </match>
    <match>
        <test name="family"><string>Times</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Tinos</string>
        </edit>
    </match>
    <match>
        <test name="family"><string>Times New Roman</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Tinos</string>
        </edit>
    </match>
    <match> <!-- NOT metric-compatible! -->
        <test name="family"><string>Consolas</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Cousine</string>
        </edit>
    </match>
    <match>
        <test name="family"><string>Courier</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Cousine</string>
        </edit>
    </match>
    <match>
        <test name="family"><string>Courier New</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Cousine</string>
        </edit>
    </match>
    <match>
        <test name="family"><string>Calibri</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Carlito</string>
        </edit>
    </match>
    <match>
        <test name="family"><string>Cambria</string></test>
        <edit name="family" mode="assign" binding="strong">
        <string>Caladea</string>
        </edit>
    </match> 
    </fontconfig>
  '';

  confPkg = pkgs.runCommand "metric-compatible-fonts-conf" {
    preferLocalBuild = true;
  } ''
    support_folder=$out/etc/fonts/conf.d
    mkdir -p $support_folder

    # 30-metric-compatible-fonts.conf
    ln -s ${preferConf}       $support_folder/30-metric-compatible-fonts.conf
  '';

  ttf-croscore = (import (import ../../flake-compat.nix).inputs.nixpkgs-croscore {
    inherit (pkgs) system;
  }).noto-fonts.overrideAttrs(oldAttrs: {
    pname = "ttf-croscore";

    installPhase = ''
      install -m444 -Dt $out/share/fonts/truetype/croscore hinted/*/{Arimo,Cousine,Tinos}/*.ttf
    '';

    meta = oldAttrs.meta // {
      description = "Chrome OS core fonts";
      longDescription = "This package includes the Arimo, Cousine, and Tinos fonts.";
    };
  });
in {
  options = {
    fonts.fontconfig = {
      crOSMaps = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Map specific families to CrOS ones.
        '';
      };
    };
  };

  config = mkIf cfg.crOSMaps {
    fonts.fonts = with pkgs; [
      ttf-croscore
      carlito
      caladea
    ];
    fonts.fontconfig.confPackages = [ confPkg ];
  };
}

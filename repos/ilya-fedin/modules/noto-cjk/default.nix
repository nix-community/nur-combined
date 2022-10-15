{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.fonts.fontconfig;

  preferConf = pkgs.writeText "fc-70-noto-cjk.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
        <match target="pattern">
            <test name="lang">
                <string>ja</string>
            </test>
            <test name="family">
                <string>serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Serif CJK JP</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>ko</string>
            </test>
            <test name="family">
                <string>serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Serif CJK KR</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-cn</string>
            </test>
            <test name="family">
                <string>serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Serif CJK SC</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-tw</string>
            </test>
            <test name="family">
                <string>serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Serif CJK TC</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-hk</string>
            </test>
            <test name="family">
                <string>serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Serif CJK HK</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>ja</string>
            </test>
            <test name="family">
                <string>sans-serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans CJK JP</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>ko</string>
            </test>
            <test name="family">
                <string>sans-serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans CJK KR</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-cn</string>
            </test>
            <test name="family">
                <string>sans-serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans CJK SC</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-tw</string>
            </test>
            <test name="family">
                <string>sans-serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans CJK TC</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-hk</string>
            </test>
            <test name="family">
                <string>sans-serif</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans CJK HK</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>ja</string>
            </test>
            <test name="family">
                <string>monospace</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans Mono CJK JP</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>ko</string>
            </test>
            <test name="family">
                <string>monospace</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans Mono CJK KR</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-cn</string>
            </test>
            <test name="family">
                <string>monospace</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans Mono CJK SC</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-tw</string>
            </test>
            <test name="family">
                <string>monospace</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans Mono CJK TC</string>
            </edit>
        </match>

        <match target="pattern">
            <test name="lang">
                <string>zh-hk</string>
            </test>
            <test name="family">
                <string>monospace</string>
            </test>
            <edit name="family" mode="prepend">
                <string>Noto Sans Mono CJK HK</string>
            </edit>
        </match>
    </fontconfig>
  '';

  confPkg = pkgs.runCommand "noto-cjk-conf" {
    preferLocalBuild = true;
  } ''
    support_folder=$out/etc/fonts/conf.d
    mkdir -p $support_folder

    # 70-noto-cjk.conf
    ln -s ${preferConf}       $support_folder/70-noto-cjk.conf
  '';
in {
  options = {
    fonts.fontconfig = {
      useNotoCjk = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Add Noto CJK, a pan-CJK font.
        '';
      };
    };
  };

  config = mkIf cfg.useNotoCjk {
    fonts.fonts = [ pkgs.noto-fonts-cjk ];
    fonts.fontconfig.confPackages = [ confPkg ];
  };
}

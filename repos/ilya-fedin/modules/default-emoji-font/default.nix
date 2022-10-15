{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.fonts.fontconfig;

  emojiCfg = cfg.defaultFonts.emoji;

  emojiConfs = listToAttrs (map (emojiName: nameValuePair emojiName (pkgs.writeText "fc-75-${replaceStrings [ " " ] [ "" ] emojiName}.conf" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>

        <!--
        Treat this file as a reference and modify as necessary if you are not satisfied with the results.


        This config attempts to guarantee that colorful emojis from ${emojiName} will be displayed,
        no matter how badly the apps and websites are written.

        It uses a few different tricks, some of which introduce conflicts with other fonts.
        -->


        <!--
        This adds ${emojiName} as a final fallback font for the default font families.
        In this case, ${emojiName} will be selected if and only if no other font can provide a given symbol.

        Note, usually other fonts will have some glyphs available (especilly Symbola font),
        causing some emojis to be black&white and ugly.
        -->
        <match target="pattern">
            <test name="family"><string>sans</string></test>
            <edit name="family" mode="append"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test name="family"><string>serif</string></test>
            <edit name="family" mode="append"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test name="family"><string>sans-serif</string></test>
            <edit name="family" mode="append"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test name="family"><string>monospace</string></test>
            <edit name="family" mode="append"><string>${emojiName}</string></edit>
        </match>

        <!--
        It seems Symbola and DejaVu fonts are often selected as a fallback font before ${emojiName}.
        This will try to remove Symbola and DejaVu fonts from the list of fallback fonts.
        -->
        <selectfont>
            <rejectfont>
                <pattern>
                    <patelt name="family">
                        <string>Symbola</string>
                    </patelt>
                </pattern>
                <pattern>
                    <patelt name="family">
                        <string>DejaVu Sans</string>
                    </patelt>
                </pattern>
                <pattern>
                    <patelt name="family">
                        <string>DejaVu Serif</string>
                    </patelt>
                </pattern>
                <pattern>
                    <patelt name="family">
                        <string>DejaVu Sans Mono</string>
                    </patelt>
                </pattern>
            </rejectfont>
        </selectfont>

        <!--
        Recognize alternative ways of writing ${emojiName} family name.
        -->
        <match target="pattern">
            <test qual="any" name="family"><string>EmojiOne</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Emoji One</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>EmojiOne Color</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>EmojiOne Mozilla</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <!--
        Use ${emojiName} when other popular fonts are being specifically requested.

        It is quite common that websites would only request Apple and Google emoji fonts, and then fallback to b&w Symbola.
        These aliases will make ${emojiName} be selected in such cases to provide good-looking emojis.
        -->
        <match target="pattern">
            <test qual="any" name="family"><string>Apple Color Emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Segoe UI Symbol</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Noto Color Emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>NotoColorEmoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Android Emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Noto Emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Twitter Color Emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Twemoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Twemoji Mozilla</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>TwemojiMozilla</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>EmojiTwo</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Emoji Two</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>EmojiSymbols</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>

        <match target="pattern">
            <test qual="any" name="family"><string>Symbola</string></test>
            <edit name="family" mode="assign" binding="same"><string>${emojiName}</string></edit>
        </match>
    </fontconfig>
  '')) emojiCfg);

  confPkg = pkgs.runCommand "default-emoji-font-conf" {
    preferLocalBuild = true;
  } ''
    support_folder=$out/etc/fonts/conf.d

    mkdir -p $support_folder

    ${concatStrings (mapAttrsToList (emojiName: emojiConf: ''
      # 75-${emojiConf}.conf
      ln -s ${emojiConf}       $support_folder/75-${replaceStrings [ " " ] [ "" ] emojiName}.conf
    '') emojiConfs)}
  '';
in {
  options = {
    fonts.fontconfig = {
      extraEmojiConfiguration = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Add a config for better emoji support.
        '';
      };
    };
  };

  config = mkIf (cfg.extraEmojiConfiguration && emojiCfg != []) {
    fonts.fontconfig.useEmbeddedBitmaps = true;
    fonts.fontconfig.confPackages = [ confPkg ];
  };
}
